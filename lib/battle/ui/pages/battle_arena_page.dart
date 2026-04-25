import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/battle/ui/blocs/battle_bloc.dart';
import 'package:vocabu_rex_mobile/battle/domain/entities/battle_entities.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class BattleArenaPage extends StatefulWidget {
  const BattleArenaPage({super.key});
  @override
  State<BattleArenaPage> createState() => _BattleArenaPageState();
}

class _BattleArenaPageState extends State<BattleArenaPage> with TickerProviderStateMixin {
  Timer? _timer;
  int _remainingMs = 15000;
  String? _selectedAnswer;

  // Animation controllers
  late AnimationController _shakeMyCtrl;
  late AnimationController _shakeOppCtrl;
  late AnimationController _damagePopupCtrl;
  late AnimationController _timerPulseCtrl;

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
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeMyCtrl.dispose();
    _shakeOppCtrl.dispose();
    _damagePopupCtrl.dispose();
    _timerPulseCtrl.dispose();
    super.dispose();
  }

  void _startTimer(int timeLimit) {
    _timer?.cancel();
    _remainingMs = timeLimit;
    _selectedAnswer = null;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() { _remainingMs -= 100; });
      if (_remainingMs <= 0) {
        t.cancel();
        context.read<BattleBloc>().add(BattleSubmitAnswer(answer: '', timeMs: timeLimit));
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BattleBloc, BattleState>(
      listener: (ctx, st) {
        if (st is BattleRoundActive) {
          if (st.lastDamage == null) {
            _startTimer(st.question.timeLimit);
          } else {
            // Damage event — trigger animation
            _triggerDamageAnim(st);
          }
        }
        if (st is BattleKOState || st is BattleMatchResultState) {
          _timer?.cancel();
          _showResultDialog(ctx, st);
        }
      },
      builder: (ctx, st) {
        return Scaffold(
          backgroundColor: const Color(0xFF1A1A2E),
          body: SafeArea(child: _body(ctx, st)),
        );
      },
    );
  }

  void _triggerDamageAnim(BattleRoundActive st) {
    final dmg = st.lastDamage!;
    final bloc = context.read<BattleBloc>();
    final myId = bloc.myUserId ?? '';

    if (dmg.isCorrect && dmg.damage > 0) {
      // Attacker dealt damage to opponent
      if (dmg.attackerId == myId) {
        // I attacked → shake opponent
        _shakeOppCtrl.forward(from: 0);
        setState(() {
          _damageText = '-${dmg.damage}';
          _damageColor = AppColors.featherGreen;
          _damageIsMe = false;
        });
      } else {
        // Opponent attacked me → shake me
        _shakeMyCtrl.forward(from: 0);
        setState(() {
          _damageText = '-${dmg.damage}';
          _damageColor = AppColors.cardinal;
          _damageIsMe = true;
        });
      }
    } else if (dmg.selfDamage > 0) {
      // Wrong answer → self-damage
      if (dmg.attackerId == myId) {
        _shakeMyCtrl.forward(from: 0);
        setState(() {
          _damageText = '-${dmg.selfDamage}';
          _damageColor = AppColors.bee;
          _damageIsMe = true;
        });
      } else {
        _shakeOppCtrl.forward(from: 0);
        setState(() {
          _damageText = '-${dmg.selfDamage}';
          _damageColor = AppColors.bee;
          _damageIsMe = false;
        });
      }
    }
    _damagePopupCtrl.forward(from: 0);
  }

  Widget _body(BuildContext ctx, BattleState st) {
    if (st is BattleMatchReady) return _countdown(st);
    if (st is BattleRoundActive) return _combatView(ctx, st);
    return const Center(child: Text('Đang chuẩn bị...', style: TextStyle(color: Colors.white70, fontSize: 18)));
  }

  // ─── 3-2-1 Countdown ───
  Widget _countdown(BattleMatchReady st) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1A1A2E), Color(0xFF16213E)]),
      ),
      child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _combatAvatar(st.match.player1.displayName, const Color(0xFF4FC3F7), st.match.player1.currentLevel),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('⚔️', style: TextStyle(fontSize: 44)),
          ),
          _combatAvatar(st.match.player2.displayName, const Color(0xFFFF7043), st.match.player2.currentLevel),
        ]),
        const SizedBox(height: 32),
        const Text('Trận đấu sắp bắt đầu!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'DuolingoFeather')),
        const SizedBox(height: 8),
        Text('${st.match.totalRounds} rounds • ${st.match.maxHp} HP', style: const TextStyle(fontSize: 14, color: Colors.white54)),
      ])),
    );
  }

  Widget _combatAvatar(String name, Color c, int level) {
    return Column(children: [
      Container(
        width: 72, height: 72,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [c, c.withValues(alpha: 0.7)]),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 3),
          boxShadow: [BoxShadow(color: c.withValues(alpha: 0.4), blurRadius: 16, spreadRadius: 2)],
        ),
        child: Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white))),
      ),
      const SizedBox(height: 8),
      SizedBox(width: 90, child: Text(name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white))),
      Text('Lv.$level', style: TextStyle(fontSize: 12, color: c)),
    ]);
  }

  // ─── Main Combat View ───
  Widget _combatView(BuildContext ctx, BattleRoundActive st) {
    final q = st.question;
    final seconds = (_remainingMs / 1000).ceil().clamp(0, 15);
    final timerCritical = seconds <= 5;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)]),
      ),
      child: Column(children: [
        const SizedBox(height: 8),

        // ─── TOP: Avatars + HP Bars ───
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            // My side (left)
            Expanded(child: _playerPanel(
              name: st.match.player1.displayName,
              hp: st.myHp,
              maxHp: st.maxHp,
              color: const Color(0xFF4FC3F7),
              isLeft: true,
              shakeCtrl: _shakeMyCtrl,
            )),
            // VS + Round
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(children: [
                const Text('⚔️', style: TextStyle(fontSize: 28)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${q.roundNumber}/${st.match.totalRounds}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white70)),
                ),
              ]),
            ),
            // Opponent side (right)
            Expanded(child: _playerPanel(
              name: st.match.player2.displayName,
              hp: st.opponentHp,
              maxHp: st.maxHp,
              color: const Color(0xFFFF7043),
              isLeft: false,
              shakeCtrl: _shakeOppCtrl,
            )),
          ]),
        ),

        const SizedBox(height: 12),

        // ─── Timer ───
        AnimatedBuilder(
          animation: _timerPulseCtrl,
          builder: (_, __) {
            final scale = timerCritical ? 1.0 + _timerPulseCtrl.value * 0.15 : 1.0;
            return Transform.scale(
              scale: scale,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: timerCritical ? AppColors.cardinal.withValues(alpha: 0.2) : Colors.white12,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: timerCritical ? AppColors.cardinal : Colors.white24),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.timer, color: timerCritical ? AppColors.cardinal : Colors.white70, size: 18),
                  const SizedBox(width: 6),
                  Text('$seconds s', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: timerCritical ? AppColors.cardinal : Colors.white, fontFamily: 'DuolingoFeather')),
                ]),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // ─── Damage Popup ───
        SizedBox(
          height: 40,
          child: AnimatedBuilder(
            animation: _damagePopupCtrl,
            builder: (_, __) {
              if (!_damagePopupCtrl.isAnimating && _damagePopupCtrl.value == 0) return const SizedBox.shrink();
              final opacity = (1 - _damagePopupCtrl.value).clamp(0.0, 1.0);
              final offset = -30 * _damagePopupCtrl.value;
              return Opacity(
                opacity: opacity,
                child: Transform.translate(
                  offset: Offset(_damageIsMe ? -40 : 40, offset),
                  child: Text(_damageText, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: _damageColor, fontFamily: 'DuolingoFeather', shadows: [Shadow(color: _damageColor.withValues(alpha: 0.5), blurRadius: 8)])),
                ),
              );
            },
          ),
        ),

        // ─── Question Card ───
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF233554), Color(0xFF1A1A2E)]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 4))],
                ),
                child: Text(q.prompt, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'DuolingoFeather', height: 1.4)),
              ),
              const SizedBox(height: 16),
              // Options grid (2 columns)
              Expanded(
                child: _optionsGrid(ctx, st, q.options),
              ),
              if (st.myAnswerSubmitted)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white38)),
                    SizedBox(width: 8),
                    Text('Đang chờ đối thủ...', style: TextStyle(fontSize: 13, color: Colors.white38, fontStyle: FontStyle.italic)),
                  ]),
                ),
            ]),
          ),
        ),
      ]),
    );
  }

  // ─── Player Panel (avatar + HP bar) ───
  Widget _playerPanel({
    required String name,
    required int hp,
    required int maxHp,
    required Color color,
    required bool isLeft,
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
        final shake = sin(shakeCtrl.value * pi * 6) * 6 * (1 - shakeCtrl.value);
        return Transform.translate(offset: Offset(shake, 0), child: child);
      },
      child: Column(children: [
        // Avatar
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
            shape: BoxShape.circle,
            border: Border.all(color: hpCritical ? AppColors.cardinal : Colors.white24, width: 2),
            boxShadow: [if (hpCritical) BoxShadow(color: AppColors.cardinal.withValues(alpha: 0.5), blurRadius: 12)],
          ),
          child: Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white))),
        ),
        const SizedBox(height: 4),
        // Name
        SizedBox(width: 80, child: Text(name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70))),
        const SizedBox(height: 4),
        // HP Bar
        SizedBox(
          width: 100, height: 12,
          child: Stack(children: [
            Container(decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(6))),
            FractionallySizedBox(
              widthFactor: hpRatio,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [hpColor, hpColor.withValues(alpha: 0.7)]),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [BoxShadow(color: hpColor.withValues(alpha: 0.5), blurRadius: 6)],
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 2),
        Text('$hp/$maxHp', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: hpColor)),
      ]),
    );
  }

  // ─── Options Grid ───
  Widget _optionsGrid(BuildContext ctx, BattleRoundActive st, List<String> options) {
    if (options.isEmpty) {
      return const Center(child: Text('Không có đáp án', style: TextStyle(color: Colors.white38)));
    }

    // 2-column layout
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.5,
      ),
      itemCount: options.length,
      itemBuilder: (_, i) => _optionTile(ctx, st, options[i]),
    );
  }

  Widget _optionTile(BuildContext ctx, BattleRoundActive st, String opt) {
    final isSelected = _selectedAnswer == opt;
    final disabled = st.myAnswerSubmitted;

    return GestureDetector(
      onTap: disabled ? null : () {
        setState(() => _selectedAnswer = opt);
        _timer?.cancel();
        final elapsed = st.question.timeLimit - _remainingMs;
        ctx.read<BattleBloc>().add(BattleSubmitAnswer(answer: opt, timeMs: elapsed));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)])
              : const LinearGradient(colors: [Color(0xFF233554), Color(0xFF1A2744)]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF4FC3F7) : Colors.white12,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: const Color(0xFF4FC3F7).withValues(alpha: 0.3), blurRadius: 12)]
              : null,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(opt, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  // ─── Result Dialog (KO or Match End) ───
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

    final outcome = result.winnerId == null ? 'DRAW' : (result.winnerId == myUserId ? 'WIN' : 'LOSE');
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
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Icon
            Container(
              width: 88, height: 88,
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: c.withValues(alpha: 0.3), blurRadius: 20)],
              ),
              child: Icon(icon, color: c, size: 48),
            ),
            const SizedBox(height: 16),
            Text(title, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: c, fontFamily: 'DuolingoFeather')),
            const SizedBox(height: 12),
            // HP remaining
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _hpResultChip('Bạn', result.player1Hp, result.player1Hp > result.player2Hp ? AppColors.featherGreen : AppColors.cardinal),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('vs', style: TextStyle(color: Colors.white38, fontSize: 16))),
              _hpResultChip('Đối thủ', result.player2Hp, result.player2Hp > result.player1Hp ? AppColors.featherGreen : AppColors.cardinal),
            ]),
            const SizedBox(height: 16),
            Text('+${result.xpEarned} XP', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: c, fontFamily: 'DuolingoFeather')),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(ctx).pop();
                  ctx.read<BattleBloc>().add(BattleReset());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: c,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                child: const Text('Quay lại', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'DuolingoFeather')),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _hpResultChip(String label, int hp, Color c) {
    return Column(children: [
      Text('$hp HP', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: c, fontFamily: 'DuolingoFeather')),
      Text(label, style: const TextStyle(fontSize: 13, color: Colors.white54)),
    ]);
  }
}
