import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/battle/ui/blocs/battle_bloc.dart';
import 'package:vocabu_rex_mobile/battle/domain/entities/battle_entities.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/word_tiles/app_choice_tile.dart';
import 'package:vocabu_rex_mobile/theme/widgets/challenges/challenge.dart';
import 'package:vocabu_rex_mobile/theme/widgets/speech_bubbles/speech_bubble.dart';

class BattleArenaPage extends StatefulWidget {
  const BattleArenaPage({super.key});
  @override
  State<BattleArenaPage> createState() => _BattleArenaPageState();
}

class _BattleArenaPageState extends State<BattleArenaPage> with TickerProviderStateMixin {
  Timer? _timer;
  int _remainingMs = 15000;
  int _selectedOptionIndex = -1;
  bool _answered = false;

  // Animation controllers
  late AnimationController _shakeMyCtrl;
  late AnimationController _shakeOppCtrl;
  late AnimationController _damagePopupCtrl;
  late AnimationController _timerPulseCtrl;
  late AnimationController _optionEntryCtrl;

  // Damage popup state
  String _damageText = '';
  bool _damageIsMe = false;
  Color _damageColor = AppColors.cardinal;

  @override
  void initState() {
    super.initState();
    _shakeMyCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeOppCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _damagePopupCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _timerPulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
      ..repeat(reverse: true);
    _optionEntryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeMyCtrl.dispose();
    _shakeOppCtrl.dispose();
    _damagePopupCtrl.dispose();
    _timerPulseCtrl.dispose();
    _optionEntryCtrl.dispose();
    super.dispose();
  }

  void _startTimer(int timeLimit) {
    _timer?.cancel();
    _remainingMs = timeLimit;
    _selectedOptionIndex = -1;
    _answered = false;
    _optionEntryCtrl.forward(from: 0);
    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() { _remainingMs -= 100; });
      if (_remainingMs <= 0) {
        t.cancel();
        context.read<BattleBloc>().add(BattleSubmitAnswer(answer: '', timeMs: timeLimit));
      }
    });
  }

  void _triggerDamageAnim(BattleRoundActive st) {
    final dmg = st.lastDamage!;
    final myId = context.read<BattleBloc>().myUserId ?? '';

    if (dmg.isCorrect && dmg.damage > 0) {
      if (dmg.attackerId == myId) {
        _shakeOppCtrl.forward(from: 0);
        setState(() { _damageText = '-${dmg.damage}'; _damageColor = AppColors.featherGreen; _damageIsMe = false; });
      } else {
        _shakeMyCtrl.forward(from: 0);
        setState(() { _damageText = '-${dmg.damage}'; _damageColor = AppColors.cardinal; _damageIsMe = true; });
      }
    } else if (dmg.selfDamage > 0) {
      if (dmg.attackerId == myId) {
        _shakeMyCtrl.forward(from: 0);
        setState(() { _damageText = '-${dmg.selfDamage}'; _damageColor = AppColors.bee; _damageIsMe = true; });
      } else {
        _shakeOppCtrl.forward(from: 0);
        setState(() { _damageText = '-${dmg.selfDamage}'; _damageColor = AppColors.bee; _damageIsMe = false; });
      }
    }
    _damagePopupCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BattleBloc, BattleState>(
      listener: (ctx, st) {
        if (st is BattleRoundActive && st.lastDamage == null) {
          _startTimer(st.question.timeLimit);
        } else if (st is BattleRoundActive && st.lastDamage != null) {
          _triggerDamageAnim(st);
        }
        if (st is BattleKOState || st is BattleMatchResultState) {
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
    if (st is BattleRoundActive) return _combatView(ctx, st);
    return const Center(child: Text('Đang chuẩn bị...', style: TextStyle(fontSize: 18, color: AppColors.wolf)));
  }

  // ═══════════════════════════════════════════════════
  // 3-2-1 Countdown
  // ═══════════════════════════════════════════════════
  Widget _countdown(BattleMatchReady st) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]),
      ),
      child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _countdownAvatar(st.match.player1.displayName, AppColors.macaw, st.match.player1.currentLevel),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: const Text('⚔️', style: TextStyle(fontSize: 44)),
          ),
          _countdownAvatar(st.match.player2.displayName, AppColors.cardinal, st.match.player2.currentLevel),
        ]),
        SizedBox(height: 32.h),
        Text('Trận đấu sắp bắt đầu!', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'DuolingoFeather')),
        SizedBox(height: 8.h),
        Text('${st.match.totalRounds} rounds • ${st.match.maxHp} HP', style: TextStyle(fontSize: 14.sp, color: Colors.white54)),
      ])),
    );
  }

  Widget _countdownAvatar(String name, Color c, int level) {
    return Column(children: [
      Container(
        width: 72.w, height: 72.w,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [c, c.withValues(alpha: 0.7)]),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 3),
          boxShadow: [BoxShadow(color: c.withValues(alpha: 0.4), blurRadius: 16, spreadRadius: 2)],
        ),
        child: Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.w900, color: Colors.white))),
      ),
      SizedBox(height: 8.h),
      SizedBox(width: 90.w, child: Text(name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white))),
      Text('Lv.$level', style: TextStyle(fontSize: 12.sp, color: c)),
    ]);
  }

  // ═══════════════════════════════════════════════════
  // Main Combat View
  // ═══════════════════════════════════════════════════
  Widget _combatView(BuildContext ctx, BattleRoundActive st) {
    final q = st.question;
    final seconds = (_remainingMs / 1000).ceil().clamp(0, 15);
    final timerCritical = seconds <= 5;

    return Column(children: [
      // ── Dark Header: HP Bars + Avatars ──
      Container(
        padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 12.h),
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]),
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
        ),
        child: Column(children: [
          // Player panels row
          Row(children: [
            Expanded(child: _hpPanel(
              name: st.match.player1.displayName,
              hp: st.myHp, maxHp: st.maxHp,
              color: AppColors.macaw, isLeft: true,
              shakeCtrl: _shakeMyCtrl,
            )),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(children: [
                const Text('⚔️', style: TextStyle(fontSize: 24)),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10)),
                  child: Text('${q.roundNumber}/${st.match.totalRounds}', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: Colors.white70)),
                ),
              ]),
            ),
            Expanded(child: _hpPanel(
              name: st.match.player2.displayName,
              hp: st.opponentHp, maxHp: st.maxHp,
              color: AppColors.cardinal, isLeft: false,
              shakeCtrl: _shakeOppCtrl,
            )),
          ]),

          SizedBox(height: 6.h),

          // Timer
          AnimatedBuilder(
            animation: _timerPulseCtrl,
            builder: (_, __) {
              final scale = timerCritical ? 1.0 + _timerPulseCtrl.value * 0.12 : 1.0;
              return Transform.scale(
                scale: scale,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: timerCritical ? AppColors.cardinal.withValues(alpha: 0.25) : Colors.white12,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: timerCritical ? AppColors.cardinal : Colors.white24),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.timer, color: timerCritical ? AppColors.cardinal : Colors.white70, size: 16.sp),
                    SizedBox(width: 4.w),
                    Text('$seconds', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: timerCritical ? AppColors.cardinal : Colors.white, fontFamily: 'DuolingoFeather')),
                  ]),
                ),
              );
            },
          ),
        ]),
      ),

      // ── Damage Popup ──
      SizedBox(
        height: 36.h,
        child: AnimatedBuilder(
          animation: _damagePopupCtrl,
          builder: (_, __) {
            if (!_damagePopupCtrl.isAnimating && _damagePopupCtrl.value == 0) return const SizedBox.shrink();
            final opacity = (1 - _damagePopupCtrl.value).clamp(0.0, 1.0);
            final offset = -25.0 * _damagePopupCtrl.value;
            return Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(_damageIsMe ? -30.w : 30.w, offset),
                child: Text(_damageText, style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w900, color: _damageColor, fontFamily: 'DuolingoFeather', shadows: [Shadow(color: _damageColor.withValues(alpha: 0.4), blurRadius: 6)])),
              ),
            );
          },
        ),
      ),

      // ── Exercise-style Question + Options (white area) ──
      Expanded(child: _exerciseArea(ctx, st, q)),
    ]);
  }

  // ═══════════════════════════════════════════════════
  // Exercise-style question area (reuses ChoiceTile + CharacterChallenge)
  // ═══════════════════════════════════════════════════
  Widget _exerciseArea(BuildContext ctx, BattleRoundActive st, BattleQuestionEntity q) {
    String challengeTitle;
    switch (q.questionType) {
      case 'fill_blank':
        challengeTitle = 'Điền vào chỗ trống';
        break;
      case 'listen_choose':
        challengeTitle = 'Chọn từ bạn nghe được';
        break;
      default:
        challengeTitle = 'Chọn đáp án đúng';
    }

    return Container(
      color: AppColors.snow,
      child: Column(children: [
        SizedBox(height: 12.h),

        // Challenge header (CharacterChallenge — same as exercise)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: CharacterChallenge(
            challengeTitle: challengeTitle,
            challengeContent: Text(
              q.prompt,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            character: Container(
              width: 70.w, height: 70.w,
              decoration: BoxDecoration(
                color: AppColors.macaw.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.bolt, size: 36.sp, color: AppColors.macaw),
            ),
            characterPosition: CharacterPosition.left,
            variant: SpeechBubbleVariant.neutral,
          ),
        ),

        SizedBox(height: 16.h),

        // Options list (ChoiceTile — same as exercise)
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            itemCount: q.options.length,
            itemBuilder: (_, index) {
              final option = q.options[index];

              // Determine tile state
              ChoiceTileState tileState = ChoiceTileState.defaults;
              if (_selectedOptionIndex >= 0 && index == _selectedOptionIndex) {
                tileState = ChoiceTileState.selected;
              }

              // Stagger animation
              final delay = (index * 0.12).clamp(0.0, 0.8);
              final slideAnim = Tween<double>(begin: 40, end: 0).animate(
                CurvedAnimation(parent: _optionEntryCtrl, curve: Interval(delay, delay + 0.5, curve: Curves.easeOutCubic)),
              );
              final fadeAnim = Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(parent: _optionEntryCtrl, curve: Interval(delay, delay + 0.5, curve: Curves.easeIn)),
              );

              return AnimatedBuilder(
                animation: _optionEntryCtrl,
                builder: (_, __) {
                  return Transform.translate(
                    offset: Offset(0, slideAnim.value),
                    child: Opacity(
                      opacity: fadeAnim.value.clamp(0.0, 1.0),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 6.h),
                        child: ChoiceTile(
                          text: option,
                          state: tileState,
                          onPressed: _answered ? () {} : () => _selectAndSubmit(ctx, st, index),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Waiting indicator
        if (st.myAnswerSubmitted)
          Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(width: 14.w, height: 14.w, child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.wolf)),
              SizedBox(width: 8.w),
              Text('Đang chờ đối thủ...', style: TextStyle(fontSize: 13.sp, color: AppColors.wolf, fontStyle: FontStyle.italic)),
            ]),
          ),
      ]),
    );
  }

  void _selectAndSubmit(BuildContext ctx, BattleRoundActive st, int index) {
    setState(() {
      _selectedOptionIndex = index;
      _answered = true;
    });
    _timer?.cancel();
    final elapsed = st.question.timeLimit - _remainingMs;
    ctx.read<BattleBloc>().add(BattleSubmitAnswer(
      answer: st.question.options[index],
      timeMs: elapsed,
    ));
  }

  // ═══════════════════════════════════════════════════
  // HP Panel (avatar + HP bar)
  // ═══════════════════════════════════════════════════
  Widget _hpPanel({
    required String name,
    required int hp, required int maxHp,
    required Color color, required bool isLeft,
    required AnimationController shakeCtrl,
  }) {
    final hpRatio = (hp / maxHp).clamp(0.0, 1.0);
    final hpColor = hpRatio > 0.6 ? AppColors.featherGreen
        : hpRatio > 0.3 ? AppColors.bee : AppColors.cardinal;
    final hpCritical = hpRatio <= 0.3;

    return AnimatedBuilder(
      animation: shakeCtrl,
      builder: (_, child) {
        final shake = sin(shakeCtrl.value * pi * 6) * 5 * (1 - shakeCtrl.value);
        return Transform.translate(offset: Offset(shake, 0), child: child);
      },
      child: Column(children: [
        // Avatar
        Container(
          width: 42.w, height: 42.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
            shape: BoxShape.circle,
            border: Border.all(color: hpCritical ? AppColors.cardinal : Colors.white24, width: 2),
            boxShadow: [if (hpCritical) BoxShadow(color: AppColors.cardinal.withValues(alpha: 0.5), blurRadius: 10)],
          ),
          child: Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: Colors.white))),
        ),
        SizedBox(height: 3.h),
        SizedBox(width: 75.w, child: Text(name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: Colors.white70))),
        SizedBox(height: 3.h),
        // HP Bar
        SizedBox(
          width: 90.w, height: 10.h,
          child: Stack(children: [
            Container(decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(5))),
            FractionallySizedBox(
              widthFactor: hpRatio,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [hpColor, hpColor.withValues(alpha: 0.7)]),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [BoxShadow(color: hpColor.withValues(alpha: 0.4), blurRadius: 4)],
                ),
              ),
            ),
          ]),
        ),
        SizedBox(height: 2.h),
        Text('$hp', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: hpColor)),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════
  // Result Dialog (KO or Match End)
  // ═══════════════════════════════════════════════════
  void _showResultDialog(BuildContext ctx, BattleState st) {
    final BattleResultEntity result;
    final String myUserId;
    bool isKO = false;

    if (st is BattleKOState) {
      result = st.result; myUserId = st.myUserId; isKO = true;
    } else if (st is BattleMatchResultState) {
      result = st.result; myUserId = st.myUserId;
    } else {
      return;
    }

    final outcome = result.winnerId == null ? 'DRAW' : (result.winnerId == myUserId ? 'WIN' : 'LOSE');
    final Color c; final String title; final IconData icon;

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
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 80.w, height: 80.w,
              decoration: BoxDecoration(color: c.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(icon, color: c, size: 44.sp),
            ),
            SizedBox(height: 14.h),
            Text(title, style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: c, fontFamily: 'DuolingoFeather')),
            SizedBox(height: 10.h),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _hpChip('Bạn', result.player1Hp, result.player1Hp >= result.player2Hp ? AppColors.featherGreen : AppColors.cardinal),
              Padding(padding: EdgeInsets.symmetric(horizontal: 10.w), child: Text('vs', style: TextStyle(color: AppColors.wolf, fontSize: 14.sp))),
              _hpChip('Đối thủ', result.player2Hp, result.player2Hp > result.player1Hp ? AppColors.featherGreen : AppColors.cardinal),
            ]),
            SizedBox(height: 12.h),
            Text('+${result.xpEarned} XP', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: c, fontFamily: 'DuolingoFeather')),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity, height: 48.h,
              child: ElevatedButton(
                onPressed: () { Navigator.of(ctx).pop(); Navigator.of(ctx).pop(); ctx.read<BattleBloc>().add(BattleReset()); },
                style: ElevatedButton.styleFrom(backgroundColor: c, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: Text('Quay lại', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'DuolingoFeather')),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _hpChip(String label, int hp, Color c) {
    return Column(children: [
      Text('$hp HP', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: c, fontFamily: 'DuolingoFeather')),
      Text(label, style: TextStyle(fontSize: 12.sp, color: AppColors.wolf)),
    ]);
  }
}
