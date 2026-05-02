import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/battle/ui/blocs/battle_bloc.dart';
import 'package:vocabu_rex_mobile/battle/ui/blocs/battle_exercise_bloc.dart';
import 'package:vocabu_rex_mobile/battle/domain/entities/battle_entities.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/exercises/multiple_choice_simple.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/exercises/fill_blank.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/core/interaction_service.dart';

/// Battle round lifecycle:
///   playing → submitted → transitioning → playing (next round)
enum _RoundPhase { playing, submitted, transitioning }

class BattleArenaPage extends StatefulWidget {
  const BattleArenaPage({super.key});
  @override
  State<BattleArenaPage> createState() => _BattleArenaPageState();
}

class _BattleArenaPageState extends State<BattleArenaPage>
    with TickerProviderStateMixin {
  Timer? _timer;
  int _remainingMs = 15000;
  bool _answered = false;
  _RoundPhase _phase = _RoundPhase.playing;
  int _lastRoundNumber = 0;

  // Managed BattleExerciseBloc — NOT via ValueKey rebuild
  BattleExerciseBloc? _exerciseBloc;
  String _currentExerciseId = '';
  ExerciseMetaEntity? _currentMeta;
  String _currentExerciseType = 'multiple_choice';

  // Animation controllers
  late AnimationController _shakeMyCtrl;
  late AnimationController _shakeOppCtrl;
  late AnimationController _damagePopupCtrl;
  late AnimationController _timerPulseCtrl;
  late AnimationController _transitionCtrl;

  // Damage popup state
  String _damageText = '';
  bool _damageIsMe = false;
  Color _damageColor = AppColors.cardinal;

  @override
  void initState() {
    super.initState();
    _shakeMyCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeOppCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _damagePopupCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _timerPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _transitionCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _exerciseBloc?.close();
    _shakeMyCtrl.dispose();
    _shakeOppCtrl.dispose();
    _damagePopupCtrl.dispose();
    _timerPulseCtrl.dispose();
    _transitionCtrl.dispose();
    super.dispose();
  }

  // ─── Round lifecycle ───

  void _prepareRound(BattleRoundActive st) {
    final q = st.question;
    // Guard: skip if this round already prepared
    if (q.roundNumber == _lastRoundNumber && _phase == _RoundPhase.playing)
      return;
    _lastRoundNumber = q.roundNumber;

    // Parse meta
    final exerciseType = q.exerciseType;
    final exerciseId = q.exerciseId ?? 'battle-${q.roundNumber}';
    ExerciseMetaEntity? meta;
    if (q.rawMeta != null) {
      try {
        meta = ExerciseMetaEntity.fromJson(q.rawMeta!, exerciseType);
      } catch (_) {}
    }
    meta ??= _fallbackMeta(q, exerciseType);

    // Dispose old bloc safely
    _exerciseBloc?.close();

    // Create fresh bloc
    _exerciseBloc = BattleExerciseBloc(
      exerciseId: exerciseId,
      exerciseType: exerciseType,
      meta: meta,
    );

    _currentExerciseId = exerciseId;
    _currentMeta = meta;
    _currentExerciseType = exerciseType;

    // Start timer + reset flags
    _timer?.cancel();
    _remainingMs = q.timeLimit;
    _answered = false;
    _phase = _RoundPhase.playing;
    _transitionCtrl.value = 1.0; // fully visible

    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _remainingMs -= 100;
      });
      if (_remainingMs <= 0) {
        t.cancel();
        _handleTimeout(q.timeLimit);
      }
    });

    setState(() {});
  }

  ExerciseMetaEntity _fallbackMeta(
    BattleQuestionEntity q,
    String exerciseType,
  ) {
    if (exerciseType == 'fill_blank') {
      return FillBlankMetaEntity(
        sentences: [
          FillBlankSentence(
            text: q.prompt,
            correctAnswer: q.options.isNotEmpty ? q.options.first : '',
            options: q.options,
          ),
        ],
      );
    }
    return MultipleChoiceMetaEntity(
      question: q.prompt,
      options: q.options
          .asMap()
          .entries
          .map((e) => MultipleChoiceOption(text: e.value, order: e.key))
          .toList(),
      correctOrder: [0],
    );
  }

  void _handleTimeout(int timeLimit) {
    if (_answered) return;
    _answered = true;
    _phase = _RoundPhase.submitted;
    context.read<BattleBloc>().add(
      BattleSubmitAnswer(answer: '', timeMs: timeLimit),
    );
    setState(() {});
  }

  void _handleExerciseAnswer(bool isCorrect) {
    if (_answered) return;
    _answered = true;
    _timer?.cancel();
    _phase = _RoundPhase.submitted;

    if (isCorrect) {
      InteractionService.playSuccess();
    } else {
      InteractionService.playError();
    }

    final elapsed = (_lastRoundNumber > 0 ? 15000 : 15000) - _remainingMs;
    final answer = isCorrect
        ? _getCorrectAnswer(_currentMeta!, _currentExerciseType)
        : '';
    context.read<BattleBloc>().add(
      BattleSubmitAnswer(answer: answer, timeMs: elapsed),
    );
    setState(() {});
  }

  void _triggerDamageAnim(BattleRoundActive st) {
    final dmg = st.lastDamage!;
    final myId = context.read<BattleBloc>().myUserId ?? '';

    if (dmg.isCorrect && dmg.damage > 0) {
      if (dmg.attackerId == myId) {
        _shakeOppCtrl.forward(from: 0);
        _damageText = '-${dmg.damage}';
        _damageColor = AppColors.featherGreen;
        _damageIsMe = false;
      } else {
        _shakeMyCtrl.forward(from: 0);
        _damageText = '-${dmg.damage}';
        _damageColor = AppColors.cardinal;
        _damageIsMe = true;
      }
    } else if (dmg.selfDamage > 0) {
      if (dmg.attackerId == myId) {
        _shakeMyCtrl.forward(from: 0);
        _damageText = '-${dmg.selfDamage}';
        _damageColor = AppColors.bee;
        _damageIsMe = true;
      } else {
        _shakeOppCtrl.forward(from: 0);
        _damageText = '-${dmg.selfDamage}';
        _damageColor = AppColors.bee;
        _damageIsMe = false;
      }
    }
    _damagePopupCtrl.forward(from: 0);
    setState(() {});
  }

  /// Smooth transition: fade out → clear → fade in new round
  void _startTransition(BattleRoundActive nextSt) {
    if (_phase == _RoundPhase.transitioning) return;
    _phase = _RoundPhase.transitioning;
    _timer?.cancel();
    setState(() {});

    // Fade out (300ms) → prepare new round → fade in (300ms)
    _transitionCtrl.reverse(from: 1.0).then((_) {
      if (!mounted) return;
      _prepareRound(nextSt);
      _transitionCtrl.forward(from: 0.0);
    });
  }

  // ─── Build ───

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BattleBloc, BattleState>(
      listener: (ctx, st) {
        if (st is BattleRoundActive) {
          if (st.lastDamage != null) {
            // Damage event → animate
            _triggerDamageAnim(st);
          } else if (st.question.roundNumber != _lastRoundNumber) {
            // New round → transition or first round
            if (_lastRoundNumber == 0) {
              _prepareRound(st); // First round, no transition needed
            } else {
              _startTransition(st);
            }
          }
        }
        if (st is BattleKOState || st is BattleMatchResultState) {
          _timer?.cancel();
          _showResultDialog(ctx, st);
        }
      },
      builder: (ctx, st) {
        return Scaffold(
          backgroundColor: AppColors.snow,
          body: SafeArea(child: _body(ctx, st)),
        );
      },
    );
  }

  Widget _body(BuildContext ctx, BattleState st) {
    if (st is BattleMatchReady) return _countdown(st);
    if (st is BattleRoundActive) return _combatView(ctx, st);
    return Center(
      child: Text(
        'Đang chuẩn bị...',
        style: TextStyle(fontSize: 18.sp, color: AppColors.wolf),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // 3-2-1 Countdown
  // ═══════════════════════════════════════════════════
  Widget _countdown(BattleMatchReady st) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _countdownAvatar(
                  st.match.player1.displayName,
                  AppColors.macaw,
                  st.match.player1.currentLevel,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: const Text('⚔️', style: TextStyle(fontSize: 44)),
                ),
                _countdownAvatar(
                  st.match.player2.displayName,
                  AppColors.cardinal,
                  st.match.player2.currentLevel,
                ),
              ],
            ),
            SizedBox(height: 32.h),
            Text(
              'Trận đấu sắp bắt đầu!',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontFamily: 'DuolingoFeather',
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '${st.match.totalRounds} rounds • ${st.match.maxHp} HP',
              style: TextStyle(fontSize: 14.sp, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _countdownAvatar(String name, Color c, int level) {
    return Column(
      children: [
        Container(
          width: 72.w,
          height: 72.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [c, c.withValues(alpha: 0.7)]),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 3),
            boxShadow: [
              BoxShadow(
                color: c.withValues(alpha: 0.4),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 30.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: 90.w,
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        Text(
          'Lv.$level',
          style: TextStyle(fontSize: 12.sp, color: c),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════
  // Main Combat View
  // ═══════════════════════════════════════════════════
  Widget _combatView(BuildContext ctx, BattleRoundActive st) {
    final seconds = (_remainingMs / 1000).ceil().clamp(0, 15);
    final timerCritical = seconds <= 5;

    return Column(
      children: [
        // ── Dark Header: HP Bars + Avatars + Timer ──
        _combatHeader(st, seconds, timerCritical),

        // ── Damage Popup ──
        _damagePopup(),

        // ── Exercise Area (with fade transition) ──
        Expanded(child: _exerciseArea()),

        // ── Status bar ──
        _statusBar(st),
      ],
    );
  }

  Widget _combatHeader(BattleRoundActive st, int seconds, bool timerCritical) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 12.h),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _hpPanel(
                  name: st.match.player1.displayName,
                  hp: st.myHp,
                  maxHp: st.maxHp,
                  color: AppColors.macaw,
                  shakeCtrl: _shakeMyCtrl,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Column(
                  children: [
                    const Text('⚔️', style: TextStyle(fontSize: 24)),
                    SizedBox(height: 2.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${st.question.roundNumber}/${st.match.totalRounds}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _hpPanel(
                  name: st.match.player2.displayName,
                  hp: st.opponentHp,
                  maxHp: st.maxHp,
                  color: AppColors.cardinal,
                  shakeCtrl: _shakeOppCtrl,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          // Timer
          AnimatedBuilder(
            animation: _timerPulseCtrl,
            builder: (_, __) {
              final scale = timerCritical
                  ? 1.0 + _timerPulseCtrl.value * 0.12
                  : 1.0;
              return Transform.scale(
                scale: scale,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: timerCritical
                        ? AppColors.cardinal.withValues(alpha: 0.25)
                        : Colors.white12,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: timerCritical
                          ? AppColors.cardinal
                          : Colors.white24,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer,
                        color: timerCritical
                            ? AppColors.cardinal
                            : Colors.white70,
                        size: 16.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '$seconds',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                          color: timerCritical
                              ? AppColors.cardinal
                              : Colors.white,
                          fontFamily: 'DuolingoFeather',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _damagePopup() {
    return SizedBox(
      height: 36.h,
      child: AnimatedBuilder(
        animation: _damagePopupCtrl,
        builder: (_, __) {
          if (!_damagePopupCtrl.isAnimating && _damagePopupCtrl.value == 0)
            return const SizedBox.shrink();
          final opacity = (1 - _damagePopupCtrl.value).clamp(0.0, 1.0);
          final offset = -25.0 * _damagePopupCtrl.value;
          return Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(_damageIsMe ? -30.w : 30.w, offset),
              child: Text(
                _damageText,
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w900,
                  color: _damageColor,
                  fontFamily: 'DuolingoFeather',
                  shadows: [
                    Shadow(
                      color: _damageColor.withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _statusBar(BattleRoundActive st) {
    if (_phase == _RoundPhase.transitioning) {
      return Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Text(
          'Chuẩn bị câu tiếp theo...',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.macaw,
          ),
        ),
      );
    }
    if (st.myAnswerSubmitted || _phase == _RoundPhase.submitted) {
      return Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 14.w,
              height: 14.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.wolf,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'Đang chờ đối thủ...',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.wolf,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }
    return SizedBox(height: 8.h);
  }

  // ═══════════════════════════════════════════════════
  // Exercise Area — managed lifecycle, smooth transition
  // ═══════════════════════════════════════════════════
  Widget _exerciseArea() {
    if (_exerciseBloc == null || _currentMeta == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FadeTransition(
      opacity: _transitionCtrl,
      child: BlocProvider<ExerciseBloc>.value(
        value: _exerciseBloc!,
        child: BlocListener<ExerciseBloc, ExerciseState>(
          listener: (context, state) {
            if (state is ExercisesLoaded && state.isCorrect != null) {
              _handleExerciseAnswer(state.isCorrect!);
            }
          },
          child: AbsorbPointer(
            absorbing: _phase != _RoundPhase.playing,
            child: Opacity(
              opacity: _phase == _RoundPhase.playing ? 1.0 : 0.6,
              child: _buildExerciseWidget(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseWidget() {
    switch (_currentExerciseType) {
      case 'fill_blank':
        return FillBlank(
          meta: _currentMeta! as FillBlankMetaEntity,
          exerciseId: _currentExerciseId,
        );
      case 'multiple_choice':
      default:
        // Always use Simple — backend guarantees correctOrder.length == 1
        return MultipleChoiceSimple(
          meta: _currentMeta! as MultipleChoiceMetaEntity,
          exerciseId: _currentExerciseId,
        );
    }
  }

  String _getCorrectAnswer(ExerciseMetaEntity meta, String exerciseType) {
    if (meta is MultipleChoiceMetaEntity) {
      final correctOpt = meta.options
          .where((o) => meta.correctOrder.contains(o.order))
          .toList();
      return correctOpt.isNotEmpty ? correctOpt.first.text : '';
    } else if (meta is FillBlankMetaEntity) {
      return meta.sentences.map((s) => s.correctAnswer).join(' ');
    }
    return '';
  }

  // ═══════════════════════════════════════════════════
  // HP Panel
  // ═══════════════════════════════════════════════════
  Widget _hpPanel({
    required String name,
    required int hp,
    required int maxHp,
    required Color color,
    required AnimationController shakeCtrl,
  }) {
    final hpRatio = (hp / maxHp).clamp(0.0, 1.0);
    final hpColor = hpRatio > 0.6
        ? AppColors.featherGreen
        : hpRatio > 0.3
        ? AppColors.bee
        : AppColors.cardinal;
    final hpCritical = hpRatio <= 0.3;

    return AnimatedBuilder(
      animation: shakeCtrl,
      builder: (_, child) {
        final shake = sin(shakeCtrl.value * pi * 6) * 5 * (1 - shakeCtrl.value);
        return Transform.translate(offset: Offset(shake, 0), child: child);
      },
      child: Column(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: hpCritical ? AppColors.cardinal : Colors.white24,
                width: 2,
              ),
              boxShadow: [
                if (hpCritical)
                  BoxShadow(
                    color: AppColors.cardinal.withValues(alpha: 0.5),
                    blurRadius: 10,
                  ),
              ],
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 3.h),
          SizedBox(
            width: 75.w,
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ),
          SizedBox(height: 3.h),
          SizedBox(
            width: 90.w,
            height: 10.h,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  widthFactor: hpRatio,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [hpColor, hpColor.withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: hpColor.withValues(alpha: 0.4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            '$hp',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: hpColor,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // Result Dialog
  // ═══════════════════════════════════════════════════
  void _showResultDialog(BuildContext ctx, BattleState st) {
    final BattleResultEntity result;
    final String myUserId;
    bool isKO = false;

    if (st is BattleKOState) {
      result = st.result;
      myUserId = st.myUserId;
      isKO = true;
    } else if (st is BattleMatchResultState) {
      result = st.result;
      myUserId = st.myUserId;
    } else {
      return;
    }

    final outcome = result.winnerId == null
        ? 'DRAW'
        : (result.winnerId == myUserId ? 'WIN' : 'LOSE');
    final Color c;
    final String title;
    final IconData icon;

    switch (outcome) {
      case 'WIN':
        c = AppColors.featherGreen;
        title = isKO ? 'KO! 🥊💥' : 'Chiến Thắng! 🏆';
        icon = isKO ? Icons.whatshot : Icons.emoji_events;
        break;
      case 'LOSE':
        c = AppColors.cardinal;
        title = isKO ? 'Bị Hạ Gục! 💀' : 'Thua Cuộc 😢';
        icon = isKO ? Icons.heart_broken : Icons.sentiment_dissatisfied;
        break;
      default:
        c = AppColors.macaw;
        title = 'Hòa! 🤝';
        icon = Icons.handshake;
    }

    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: c, size: 44.sp),
              ),
              SizedBox(height: 14.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w900,
                  color: c,
                  fontFamily: 'DuolingoFeather',
                ),
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _hpChip(
                    'Bạn',
                    result.player1Hp,
                    result.player1Hp >= result.player2Hp
                        ? AppColors.featherGreen
                        : AppColors.cardinal,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Text(
                      'vs',
                      style: TextStyle(color: AppColors.wolf, fontSize: 14.sp),
                    ),
                  ),
                  _hpChip(
                    'Đối thủ',
                    result.player2Hp,
                    result.player2Hp > result.player1Hp
                        ? AppColors.featherGreen
                        : AppColors.cardinal,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                '+${result.xpEarned} XP',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: c,
                  fontFamily: 'DuolingoFeather',
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(ctx).pop();
                    ctx.read<BattleBloc>().add(BattleReset());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Quay lại',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'DuolingoFeather',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hpChip(String label, int hp, Color c) {
    return Column(
      children: [
        Text(
          '$hp HP',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w900,
            color: c,
            fontFamily: 'DuolingoFeather',
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: AppColors.wolf),
        ),
      ],
    );
  }
}
