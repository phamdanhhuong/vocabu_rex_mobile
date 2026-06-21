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
import 'package:vocabu_rex_mobile/exercise/ui/widgets/exercises/fill_blank.dart';
import 'package:vocabu_rex_mobile/battle/ui/widgets/battle_multiple_choice.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import 'package:vocabu_rex_mobile/core/interaction_service.dart';
import 'package:vocabu_rex_mobile/theme/widgets/static_space_background.dart';

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

  // Projectile state
  late AnimationController _projectileCtrl;
  bool _showProjectile = false;
  bool _projectileFromMe = false;
  Color _projectileColor = AppColors.macaw;

  // Store BLoC reference for dispose cleanup
  late final BattleBloc _battleBloc;

  @override
  void initState() {
    super.initState();
    _battleBloc = context.read<BattleBloc>();
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
    _projectileCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _projectileCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showProjectile = false;
        });
        // Rung màn hình khi chưởng tới nơi
        if (_projectileFromMe) {
          _shakeOppCtrl.forward(from: 0);
        } else {
          _shakeMyCtrl.forward(from: 0);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _exerciseBloc?.close();
    // If match was not completed normally, reset to clean up
    final st = _battleBloc.state;
    if (st is BattleMatchReady || st is BattleRoundActive) {
      _battleBloc.add(BattleReset());
    }
    _shakeMyCtrl.dispose();
    _shakeOppCtrl.dispose();
    _damagePopupCtrl.dispose();
    _timerPulseCtrl.dispose();
    _transitionCtrl.dispose();
    _projectileCtrl.dispose();
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
        _projectileFromMe = true;
        _projectileColor = AppColors.macaw;
        _damageText = '-${dmg.damage}';
        _damageColor = AppColors.featherGreen;
        _damageIsMe = false;
      } else {
        _projectileFromMe = false;
        _projectileColor = AppColors.cardinal;
        _damageText = '-${dmg.damage}';
        _damageColor = AppColors.cardinal;
        _damageIsMe = true;
      }
      _showProjectile = true;
      _projectileCtrl.forward(from: 0);
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
    return ListenableBuilder(
      listenable: AppPreferences(),
      builder: (context, _) {
        final isDark = AppPreferences().isDarkMode;
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
              _showResultDialog(ctx, st, isDark);
            }
            // If state goes back to initial/error, pop this page
            if (st is BattleInitial || st is BattleError || st is BattleStatsLoaded) {
              if (Navigator.of(ctx).canPop()) {
                Navigator.of(ctx).pop();
              }
            }
          },
          builder: (ctx, st) {
            return StaticSpaceBackground(
              child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(child: _body(ctx, st, isDark)),
            ),
            );
          },
        );
      },
    );
  }

  Widget _body(BuildContext ctx, BattleState st, bool isDark) {
    if (st is BattleMatchReady) {
      // Vì VsClashScreen chạy 3 giây rồi mới vào đây, nên lúc này sắp sửa có RoundActive.
      return _countdown(st, isDark);
    }
    if (st is BattleRoundActive) {
      // If the round isn't prepared yet (just arrived), prepare it
      if (_lastRoundNumber == 0 && _exerciseBloc == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _prepareRound(st);
        });
      }
      return _combatView(ctx, st, isDark);
    }
    // Fallback: show loading while waiting for state
    return const Center(child: CircularProgressIndicator());
  }

  // ═══════════════════════════════════════════════════
  // 3-2-1 Countdown
  // ═══════════════════════════════════════════════════
  Widget _countdown(BattleMatchReady st, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? null : AppColors.snow,
        gradient: isDark ? const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
        ) : null,
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
                  isDark,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: const Text('⚔️', style: TextStyle(fontSize: 44)),
                ),
                _countdownAvatar(
                  st.match.player2.displayName,
                  AppColors.cardinal,
                  st.match.player2.currentLevel,
                  isDark,
                ),
              ],
            ),
            SizedBox(height: 32.h),
            Text(
              'Trận đấu sắp bắt đầu!',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.bodyText,
                fontFamily: 'DuolingoFeather',
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '${st.match.totalRounds} rounds • ${st.match.maxHp} HP',
              style: TextStyle(fontSize: 14.sp, color: isDark ? Colors.white54 : AppColors.hare),
            ),
          ],
        ),
      ),
    );
  }

  Widget _countdownAvatar(String name, Color c, int level, bool isDark) {
    return Column(
      children: [
        Container(
          width: 72.w,
          height: 72.w,
          decoration: BoxDecoration(
            color: isDark ? null : AppColors.snow,
            gradient: isDark ? LinearGradient(colors: [c, c.withValues(alpha: 0.7)]) : null,
            shape: BoxShape.circle,
            border: Border.all(color: isDark ? Colors.white24 : c, width: 3),
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
              color: AppColors.bodyText,
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
  Widget _combatView(BuildContext ctx, BattleRoundActive st, bool isDark) {
    final seconds = (_remainingMs / 1000).ceil().clamp(0, 15);
    final timerCritical = seconds <= 5;

    return Stack(
      children: [
        Column(
          children: [
            // ── Dark Header: HP Bars + Avatars + Timer ──
            _combatHeader(st, seconds, timerCritical, isDark),

            // ── Damage Popup ──
            _damagePopup(),

            // ── Exercise Area (with fade transition) ──
            Expanded(child: _exerciseArea()),

            // ── Status bar ──
            _statusBar(st, isDark),
          ],
        ),
        
        // ── Projectile Overlay ──
        if (_showProjectile) _buildProjectile(),
      ],
    );
  }

  Widget _buildProjectile() {
    return AnimatedBuilder(
      animation: _projectileCtrl,
      builder: (ctx, child) {
        // Màn hình ngang khoảng 400px. Left avatar ~50, Right avatar ~ 350
        final screenWidth = MediaQuery.of(context).size.width;
        final startX = _projectileFromMe ? 60.0 : screenWidth - 60.0;
        final endX = _projectileFromMe ? screenWidth - 60.0 : 60.0;
        
        final currentX = startX + (endX - startX) * _projectileCtrl.value;
        final currentY = 50.0; // Khoảng chừng Avatar height

        return Positioned(
          left: currentX - 20,
          top: currentY,
          child: Transform.rotate(
            angle: _projectileFromMe ? 0 : pi,
            child: Icon(
              Icons.flash_on,
              color: _projectileColor,
              size: 60,
              shadows: [
                Shadow(color: _projectileColor.withValues(alpha: 0.8), blurRadius: 20),
                Shadow(color: Colors.white, blurRadius: 10),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _combatHeader(BattleRoundActive st, int seconds, bool timerCritical, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161622) : AppColors.snow,
        border: Border(
          bottom: BorderSide(color: isDark ? Colors.white12 : AppColors.swan, width: 2),
        ),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Player 1 HP Panel (Left)
              Expanded(
                child: _hpPanel(
                  name: st.match.player1.displayName,
                  hp: st.myHp,
                  maxHp: st.maxHp,
                  color: AppColors.macaw,
                  shakeCtrl: _shakeMyCtrl,
                  isLeft: true,
                  isDark: isDark,
                ),
              ),
              SizedBox(width: 80.w), // Space for central clock
              // Player 2 HP Panel (Right)
              Expanded(
                child: _hpPanel(
                  name: st.match.player2.displayName,
                  hp: st.opponentHp,
                  maxHp: st.maxHp,
                  color: AppColors.cardinal,
                  shakeCtrl: _shakeOppCtrl,
                  isLeft: false,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          
          // Central Timer Clock
          Positioned(
            top: -10,
            child: AnimatedBuilder(
              animation: _timerPulseCtrl,
              builder: (_, __) {
                final scale = timerCritical ? 1.0 + _timerPulseCtrl.value * 0.15 : 1.0;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 64.w,
                    height: 64.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: timerCritical ? AppColors.cardinal : (isDark ? const Color(0xFF2A2A3C) : AppColors.snow),
                      border: Border.all(
                        color: timerCritical ? Colors.white : (isDark ? Colors.white24 : AppColors.swan),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: timerCritical ? AppColors.cardinal.withValues(alpha: 0.6) : Colors.black54,
                          blurRadius: timerCritical ? 20 : 10,
                          spreadRadius: timerCritical ? 5 : 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$seconds',
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w900,
                          color: timerCritical ? Colors.white : (isDark ? Colors.white : AppColors.bodyText),
                          fontFamily: 'DuolingoFeather',
                          shadows: timerCritical ? [
                            Shadow(color: Colors.black, blurRadius: 4, offset: const Offset(0, 2)),
                          ] : null,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Round indicator
          Positioned(
            bottom: -16,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'ROUND ${st.question.roundNumber}',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white70,
                  letterSpacing: 2,
                ),
              ),
            ),
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

  Widget _statusBar(BattleRoundActive st, bool isDark) {
    if (_phase == _RoundPhase.transitioning) {
      return Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Text(
          'Chuẩn bị câu tiếp theo...',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.macaw : AppColors.bodyText,
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
                color: isDark ? AppColors.wolf : AppColors.hare,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'Đang chờ đối thủ...',
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark ? AppColors.wolf : AppColors.hare,
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
    // ValueKey forces Flutter to create a new State for each round,
    // preventing previous round's selected answers from carrying over
    final roundKey = ValueKey('battle-round-$_lastRoundNumber');
    switch (_currentExerciseType) {
      case 'fill_blank':
        return FillBlank(
          key: roundKey,
          meta: _currentMeta! as FillBlankMetaEntity,
          exerciseId: _currentExerciseId,
        );
      case 'multiple_choice':
      default:
        return BattleMultipleChoice(
          key: roundKey,
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
    required bool isLeft,
    required bool isDark,
  }) {
    final hpRatio = (hp / maxHp).clamp(0.0, 1.0);
    final hpColor = hpRatio > 0.5 ? color : AppColors.bee;
    final hpCritical = hpRatio <= 0.3 && hp > 0;

    return AnimatedBuilder(
      animation: shakeCtrl,
      builder: (_, child) {
        final dx = sin(shakeCtrl.value * pi * 4) * 8;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: Column(
            crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              Text(
                name.toUpperCase(),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white70 : AppColors.wolf,
                  letterSpacing: 1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
                children: [
                  if (isLeft) _buildMiniAvatar(name, color, hpCritical),
                  if (isLeft) SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 18.h,
                          child: Stack(
                            children: [
                              Container(
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white12 : AppColors.swan,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: isDark ? Border.all(color: Colors.white24, width: 1) : null,
                                ),
                              ),
                              AnimatedFractionallySizedBox(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                                alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
                                widthFactor: hpRatio,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: hpColor,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLeft) SizedBox(width: 8.w),
                  if (!isLeft) _buildMiniAvatar(name, color, hpCritical),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                '$hp HP',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w900,
                  color: hpCritical ? AppColors.cardinal : (isDark ? Colors.white70 : AppColors.wolf),
                  fontFamily: 'DuolingoFeather',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniAvatar(String name, Color color, bool isCritical) {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3C),
        border: Border.all(
          color: isCritical ? AppColors.cardinal : color,
          width: 3,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // Result Dialog
  // ═══════════════════════════════════════════════════
  void _showResultDialog(BuildContext ctx, BattleState st, bool isDark) {
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
        backgroundColor: isDark ? const Color(0xFF161622) : Colors.white,
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
                    result.player1?.displayName ?? 'Bạn',
                    result.player1Hp,
                    result.player1Hp >= result.player2Hp
                        ? AppColors.featherGreen
                        : AppColors.cardinal,
                    isDark,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Text(
                      'vs',
                      style: TextStyle(color: AppColors.wolf, fontSize: 14.sp),
                    ),
                  ),
                  _hpChip(
                    result.player2?.displayName ?? 'Đối thủ',
                    result.player2Hp,
                    result.player2Hp > result.player1Hp
                        ? AppColors.featherGreen
                        : AppColors.cardinal,
                    isDark,
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
                    final bloc = ctx.read<BattleBloc>();
                    Navigator.of(ctx).pop(); // pop dialog
                    bloc.add(BattleReset()); // trigger listener to pop arena page
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
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.bodyText,
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

  Widget _hpChip(String label, int hp, Color c, bool isDark) {
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
          style: TextStyle(fontSize: 12.sp, color: isDark ? AppColors.wolf : AppColors.hare),
        ),
      ],
    );
  }
}
