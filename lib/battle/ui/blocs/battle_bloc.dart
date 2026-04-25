import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/battle/data/services/battle_api_service.dart';
import 'package:vocabu_rex_mobile/battle/data/services/battle_socket_service.dart';
import 'package:vocabu_rex_mobile/battle/domain/entities/battle_entities.dart';

// ─── Events ───

abstract class BattleEvent {}

class BattleLoadStats extends BattleEvent {}
class BattleFindMatch extends BattleEvent {}
class BattleCancelSearch extends BattleEvent {}
class BattleSubmitAnswer extends BattleEvent {
  final String answer;
  final int timeMs;
  BattleSubmitAnswer({required this.answer, required this.timeMs});
}
class BattleReset extends BattleEvent {}

// Internal socket events
class _BattleSearching extends BattleEvent { final Map<String, dynamic> data; _BattleSearching(this.data); }
class _BattleMatchFound extends BattleEvent { final Map<String, dynamic> data; _BattleMatchFound(this.data); }
class _BattleRoundStart extends BattleEvent { final Map<String, dynamic> data; _BattleRoundStart(this.data); }
class _BattleDamage extends BattleEvent { final Map<String, dynamic> data; _BattleDamage(this.data); }
class _BattleKO extends BattleEvent { final Map<String, dynamic> data; _BattleKO(this.data); }
class _BattleMatchResult extends BattleEvent { final Map<String, dynamic> data; _BattleMatchResult(this.data); }

// ─── States ───

abstract class BattleState {}

class BattleInitial extends BattleState {}

class BattleStatsLoaded extends BattleState {
  final BattleStatsEntity stats;
  final List<BattleHistoryEntity> history;
  BattleStatsLoaded({required this.stats, required this.history});
}

class BattleSearching extends BattleState {
  final String? tier;
  BattleSearching({this.tier});
}

class BattleMatchReady extends BattleState {
  final BattleMatchEntity match;
  BattleMatchReady({required this.match});
}

class BattleRoundActive extends BattleState {
  final BattleMatchEntity match;
  final BattleQuestionEntity question;
  final int myHp;
  final int opponentHp;
  final int maxHp;
  final bool myAnswerSubmitted;
  final BattleDamageEvent? lastDamage; // triggers animation

  BattleRoundActive({
    required this.match,
    required this.question,
    required this.myHp,
    required this.opponentHp,
    this.maxHp = 1000,
    this.myAnswerSubmitted = false,
    this.lastDamage,
  });

  BattleRoundActive copyWith({
    int? myHp,
    int? opponentHp,
    bool? myAnswerSubmitted,
    BattleDamageEvent? lastDamage,
  }) {
    return BattleRoundActive(
      match: match,
      question: question,
      myHp: myHp ?? this.myHp,
      opponentHp: opponentHp ?? this.opponentHp,
      maxHp: maxHp,
      myAnswerSubmitted: myAnswerSubmitted ?? this.myAnswerSubmitted,
      lastDamage: lastDamage,
    );
  }
}

class BattleKOState extends BattleState {
  final BattleResultEntity result;
  final String myUserId;
  String get outcome {
    if (result.winnerId == null) return 'DRAW';
    return result.winnerId == myUserId ? 'WIN' : 'LOSE';
  }
  BattleKOState({required this.result, required this.myUserId});
}

class BattleMatchResultState extends BattleState {
  final BattleResultEntity result;
  final String myUserId;
  String get outcome {
    if (result.winnerId == null) return 'DRAW';
    return result.winnerId == myUserId ? 'WIN' : 'LOSE';
  }
  BattleMatchResultState({required this.result, required this.myUserId});
}

class BattleError extends BattleState {
  final String message;
  BattleError(this.message);
}

// ─── BLoC ───

class BattleBloc extends Bloc<BattleEvent, BattleState> {
  final BattleApiService apiService;
  final BattleSocketService socketService;

  BattleMatchEntity? _currentMatch;
  String? _myUserId;
  bool _amPlayer1 = true;
  List<StreamSubscription>? _subs;

  String? get myUserId => _myUserId;

  BattleBloc({
    required this.apiService,
    required this.socketService,
  }) : super(BattleInitial()) {
    on<BattleLoadStats>(_onLoadStats);
    on<BattleFindMatch>(_onFindMatch);
    on<BattleCancelSearch>(_onCancelSearch);
    on<BattleSubmitAnswer>(_onSubmitAnswer);
    on<BattleReset>(_onReset);
    on<_BattleSearching>(_onSearching);
    on<_BattleMatchFound>(_onMatchFound);
    on<_BattleRoundStart>(_onRoundStart);
    on<_BattleDamage>(_onDamage);
    on<_BattleKO>(_onKO);
    on<_BattleMatchResult>(_onMatchResult);
  }

  void setUserId(String userId) => _myUserId = userId;

  // ─── Stats ───

  Future<void> _onLoadStats(BattleLoadStats event, Emitter<BattleState> emit) async {
    try {
      final statsData = await apiService.getStats();
      final historyData = await apiService.getHistory(limit: 5);
      final stats = BattleStatsEntity.fromJson(statsData);
      final historyList = historyData
          .map((e) => BattleHistoryEntity.fromJson(e as Map<String, dynamic>))
          .toList();
      emit(BattleStatsLoaded(stats: stats, history: historyList));
    } catch (_) {
      emit(BattleStatsLoaded(
        stats: BattleStatsEntity(totalMatches: 0, wins: 0, losses: 0, draws: 0, winStreak: 0, bestWinStreak: 0),
        history: [],
      ));
    }
  }

  // ─── Matchmaking ───

  Future<void> _onFindMatch(BattleFindMatch event, Emitter<BattleState> emit) async {
    try {
      if (!socketService.isConnected) {
        await socketService.connect();
        await Future.delayed(const Duration(milliseconds: 500));
      }
      _listenToSocket();
      socketService.findMatch();
      emit(BattleSearching());
    } catch (_) {
      emit(BattleError('Không thể kết nối server'));
    }
  }

  void _onCancelSearch(BattleCancelSearch event, Emitter<BattleState> emit) {
    socketService.cancelSearch();
    _cancelSubs();
    emit(BattleInitial());
    add(BattleLoadStats());
  }

  // ─── Submit answer ───

  void _onSubmitAnswer(BattleSubmitAnswer event, Emitter<BattleState> emit) {
    if (_currentMatch == null) return;
    final current = state;
    if (current is! BattleRoundActive) return;

    socketService.submitAnswer(
      matchId: _currentMatch!.matchId,
      roundNumber: current.question.roundNumber,
      answer: event.answer,
      timeMs: event.timeMs,
    );
    emit(current.copyWith(myAnswerSubmitted: true));
  }

  void _onReset(BattleReset event, Emitter<BattleState> emit) {
    _cancelSubs();
    _currentMatch = null;
    emit(BattleInitial());
    add(BattleLoadStats());
  }

  // ─── Socket event handlers ───

  void _onSearching(_BattleSearching event, Emitter<BattleState> emit) {
    emit(BattleSearching(tier: event.data['tier']));
  }

  void _onMatchFound(_BattleMatchFound event, Emitter<BattleState> emit) {
    _currentMatch = BattleMatchEntity.fromJson(event.data);
    // The server swaps player1/player2 for player2's perspective
    // So from our view, player1 is always "me"
    _amPlayer1 = true;
    emit(BattleMatchReady(match: _currentMatch!));

    // Auto-transition to first round
    Future.delayed(const Duration(seconds: 3), () {
      if (_currentMatch?.firstRound != null) {
        add(_BattleRoundStart(event.data['firstRound']));
      }
    });
  }

  void _onRoundStart(_BattleRoundStart event, Emitter<BattleState> emit) {
    if (_currentMatch == null) return;
    final question = BattleQuestionEntity.fromJson(event.data);

    // Preserve HP from previous state
    int myHp = _currentMatch!.maxHp;
    int oppHp = _currentMatch!.maxHp;
    final current = state;
    if (current is BattleRoundActive) {
      myHp = current.myHp;
      oppHp = current.opponentHp;
    }

    emit(BattleRoundActive(
      match: _currentMatch!,
      question: question,
      myHp: myHp,
      opponentHp: oppHp,
      maxHp: _currentMatch!.maxHp,
    ));
  }

  void _onDamage(_BattleDamage event, Emitter<BattleState> emit) {
    if (_currentMatch == null) return;
    final current = state;
    if (current is! BattleRoundActive) return;

    final dmg = BattleDamageEvent.fromJson(event.data);

    // Map server's player1Hp/player2Hp to my perspective
    final myHp = _amPlayer1 ? dmg.player1Hp : dmg.player2Hp;
    final oppHp = _amPlayer1 ? dmg.player2Hp : dmg.player1Hp;

    emit(current.copyWith(
      myHp: myHp,
      opponentHp: oppHp,
      lastDamage: dmg,
    ));
  }

  void _onKO(_BattleKO event, Emitter<BattleState> emit) {
    final result = BattleResultEntity.fromJson(event.data);
    emit(BattleKOState(result: result, myUserId: _myUserId ?? ''));
    _cancelSubs();
  }

  void _onMatchResult(_BattleMatchResult event, Emitter<BattleState> emit) {
    final result = BattleResultEntity.fromJson(event.data);
    emit(BattleMatchResultState(result: result, myUserId: _myUserId ?? ''));
    _cancelSubs();
  }

  // ─── Socket subscription management ───

  void _listenToSocket() {
    _cancelSubs();
    _subs = [
      socketService.onSearching.listen((d) => add(_BattleSearching(d))),
      socketService.onMatchFound.listen((d) => add(_BattleMatchFound(d))),
      socketService.onRoundStart.listen((d) => add(_BattleRoundStart(d))),
      socketService.onDamage.listen((d) => add(_BattleDamage(d))),
      socketService.onKO.listen((d) => add(_BattleKO(d))),
      socketService.onMatchResult.listen((d) => add(_BattleMatchResult(d))),
      socketService.onError.listen((_) => add(BattleReset())),
    ];
  }

  void _cancelSubs() {
    if (_subs != null) {
      for (final s in _subs!) { s.cancel(); }
      _subs = null;
    }
  }

  @override
  Future<void> close() {
    _cancelSubs();
    socketService.dispose();
    return super.close();
  }
}
