import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/battle/ui/blocs/battle_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class BattleArenaPage extends StatefulWidget {
  const BattleArenaPage({Key? key}) : super(key: key);
  @override
  State<BattleArenaPage> createState() => _BattleArenaPageState();
}

class _BattleArenaPageState extends State<BattleArenaPage> {
  Timer? _timer;
  int _remainingMs = 15000;
  String? _selectedAnswer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(int timeLimit) {
    _timer?.cancel();
    _remainingMs = timeLimit;
    _selectedAnswer = null;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      setState(() { _remainingMs -= 100; });
      if (_remainingMs <= 0) {
        t.cancel();
        // Auto-submit empty answer on timeout
        context.read<BattleBloc>().add(BattleSubmitAnswer(answer: '', timeMs: timeLimit));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BattleBloc, BattleState>(
      listener: (ctx, st) {
        if (st is BattleRoundActive) {
          _startTimer(st.question.timeLimit);
        }
        if (st is BattleMatchResultState) {
          _timer?.cancel();
          _showResultDialog(ctx, st);
        }
      },
      builder: (ctx, st) {
        return Scaffold(
          backgroundColor: AppColors.polar,
          body: SafeArea(child: _body(ctx, st)),
        );
      },
    );
  }

  Widget _body(BuildContext ctx, BattleState st) {
    if (st is BattleMatchReady) return _countdown(st);
    if (st is BattleRoundActive) return _roundView(ctx, st);
    if (st is BattleRoundResultState) return _roundResult(ctx, st);
    if (st is BattleMatchResultState) return const Center(child: CircularProgressIndicator());
    return const Center(child: Text('Đang chuẩn bị...'));
  }

  // ─── 3-2-1 Countdown ───
  Widget _countdown(BattleMatchReady st) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _playerAvatar(st.match.player1.displayName, AppColors.macaw),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('VS', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.cardinal, fontFamily: 'DuolingoFeather'))),
        _playerAvatar(st.match.player2.displayName, AppColors.cardinal),
      ]),
      const SizedBox(height: 32),
      const Text('Trận đấu sắp bắt đầu!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.bodyText, fontFamily: 'DuolingoFeather')),
    ]));
  }

  Widget _playerAvatar(String name, Color c) {
    return Column(children: [
      Container(width: 64, height: 64, decoration: BoxDecoration(color: c.withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: c, width: 3)),
        child: Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: c, fontFamily: 'DuolingoFeather')))),
      const SizedBox(height: 8),
      SizedBox(width: 80, child: Text(name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.bodyText, fontFamily: 'DuolingoFeather'))),
    ]);
  }

  // ─── Round view ───
  Widget _roundView(BuildContext ctx, BattleRoundActive st) {
    final q = st.question;
    final seconds = (_remainingMs / 1000).ceil().clamp(0, 15);
    final progress = (_remainingMs / q.timeLimit).clamp(0.0, 1.0);
    final timerColor = seconds <= 5 ? AppColors.cardinal : AppColors.macaw;

    return Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      // Top bar: scores + timer
      Row(children: [
        _scoreChip(st.match.player1.displayName, st.player1Score, AppColors.macaw),
        Expanded(child: Column(children: [
          Text('$seconds', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: timerColor, fontFamily: 'DuolingoFeather')),
          const SizedBox(height: 4),
          ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: progress, backgroundColor: AppColors.swan, valueColor: AlwaysStoppedAnimation(timerColor), minHeight: 6)),
        ])),
        _scoreChip(st.match.player2.displayName, st.player2Score, AppColors.cardinal),
      ]),
      const SizedBox(height: 8),
      // Round indicator
      Text('Câu ${q.roundNumber}/${st.match.totalRounds}', style: const TextStyle(fontSize: 14, color: AppColors.wolf, fontWeight: FontWeight.w600, fontFamily: 'DuolingoFeather')),
      const SizedBox(height: 20),
      // Question
      Container(
        width: double.infinity, padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.snow, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.swan), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Text(q.prompt, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.bodyText, fontFamily: 'DuolingoFeather')),
      ),
      const SizedBox(height: 20),
      // Options
      ...q.options.map((opt) => _optionButton(ctx, st, opt)),
      if (st.myAnswerSubmitted && !st.opponentAnswered)
        const Padding(padding: EdgeInsets.only(top: 16), child: Text('Đang chờ đối thủ...', style: TextStyle(fontSize: 14, color: AppColors.wolf, fontStyle: FontStyle.italic, fontFamily: 'DuolingoFeather'))),
    ]));
  }

  Widget _scoreChip(String name, int score, Color c) {
    return Column(children: [
      Container(width: 44, height: 44, decoration: BoxDecoration(color: c.withOpacity(0.12), shape: BoxShape.circle, border: Border.all(color: c, width: 2)),
        child: Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c)))),
      const SizedBox(height: 4),
      Text('$score', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: c, fontFamily: 'DuolingoFeather')),
    ]);
  }

  Widget _optionButton(BuildContext ctx, BattleRoundActive st, String opt) {
    final isSelected = _selectedAnswer == opt;
    final disabled = st.myAnswerSubmitted;
    return Padding(padding: const EdgeInsets.only(bottom: 10), child: GestureDetector(
      onTap: disabled ? null : () {
        setState(() => _selectedAnswer = opt);
        _timer?.cancel();
        final elapsed = st.question.timeLimit - _remainingMs;
        ctx.read<BattleBloc>().add(BattleSubmitAnswer(answer: opt, timeMs: elapsed));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.macaw.withOpacity(0.1) : AppColors.snow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppColors.macaw : AppColors.swan, width: isSelected ? 2.5 : 1.5),
        ),
        child: Text(opt, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? AppColors.macaw : AppColors.bodyText, fontFamily: 'DuolingoFeather')),
      ),
    ));
  }

  // ─── Round result ───
  Widget _roundResult(BuildContext ctx, BattleRoundResultState st) {
    final r = st.result;
    final isCorrect = st.myAnswer == r.correctAnswer;
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(isCorrect ? Icons.check_circle : Icons.cancel, color: isCorrect ? AppColors.featherGreen : AppColors.cardinal, size: 72),
      const SizedBox(height: 16),
      Text(isCorrect ? 'Chính xác! 🎉' : 'Sai rồi! 😅', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: isCorrect ? AppColors.featherGreen : AppColors.cardinal, fontFamily: 'DuolingoFeather')),
      const SizedBox(height: 8),
      Text('Đáp án: ${r.correctAnswer}', style: const TextStyle(fontSize: 16, color: AppColors.wolf, fontFamily: 'DuolingoFeather')),
      const SizedBox(height: 24),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _roundScoreChip('Bạn', r.player1Points, AppColors.macaw),
        const SizedBox(width: 32),
        _roundScoreChip('Đối thủ', r.player2Points, AppColors.cardinal),
      ]),
      const SizedBox(height: 16),
      Text('Tổng: ${r.player1TotalScore} - ${r.player2TotalScore}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.bodyText, fontFamily: 'DuolingoFeather')),
    ]));
  }

  Widget _roundScoreChip(String label, int pts, Color c) {
    return Column(children: [
      Text('+$pts', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: c, fontFamily: 'DuolingoFeather')),
      Text(label, style: const TextStyle(fontSize: 14, color: AppColors.wolf, fontFamily: 'DuolingoFeather')),
    ]);
  }

  // ─── Match result dialog ───
  void _showResultDialog(BuildContext ctx, BattleMatchResultState st) {
    final outcome = st.outcome;
    final Color c; final String title; final IconData icon;
    switch (outcome) { case 'WIN': c = AppColors.featherGreen; title = 'Chiến Thắng! 🏆'; icon = Icons.emoji_events; break; case 'LOSE': c = AppColors.cardinal; title = 'Thua Cuộc 😢'; icon = Icons.sentiment_dissatisfied; break; default: c = AppColors.macaw; title = 'Hòa! 🤝'; icon = Icons.handshake; }

    showDialog(
      context: ctx, barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 80, height: 80, decoration: BoxDecoration(color: c.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(icon, color: c, size: 48)),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: c, fontFamily: 'DuolingoFeather')),
          const SizedBox(height: 8),
          Text('${st.result.player1Score} - ${st.result.player2Score}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.bodyText, fontFamily: 'DuolingoFeather')),
          const SizedBox(height: 8),
          Text('+${st.result.xpEarned} XP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: c, fontFamily: 'DuolingoFeather')),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
            onPressed: () { Navigator.of(ctx).pop(); Navigator.of(ctx).pop(); ctx.read<BattleBloc>().add(BattleReset()); },
            style: ElevatedButton.styleFrom(backgroundColor: c, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: const Text('Quay lại', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'DuolingoFeather')),
          )),
        ])),
      ),
    );
  }
}
