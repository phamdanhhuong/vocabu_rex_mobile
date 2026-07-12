import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/submit_response_entity.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/aurora_map_background.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/typography.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import 'dart:ui';
import 'dart:math' as math;

enum PostLessonStep { overview, streak, rewards }

class PostLessonFlowPage extends StatefulWidget {
  final SubmitResponseEntity response;
  final Duration? completionTime;

  const PostLessonFlowPage({
    super.key,
    required this.response,
    this.completionTime,
  });

  @override
  State<PostLessonFlowPage> createState() => _PostLessonFlowPageState();
}

class _PostLessonFlowPageState extends State<PostLessonFlowPage> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  final List<PostLessonStep> _steps = [];
  int _currentStepIndex = 0;

  // Reward info
  int _totalGems = 0;
  int _totalCoins = 0;
  
  // Streak info
  int? _previousStreak;
  int? _currentStreak;

  // Overview Animation
  late AnimationController _overviewAnimController;
  late Animation<int> _expAnimation;
  late Animation<int> _accuracyAnimation;

  // Overlay for flying coins
  OverlayEntry? _coinsOverlay;
  final GlobalKey _walletKey = GlobalKey();
  final GlobalKey _chestKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // Determine which steps to show
    _steps.add(PostLessonStep.overview); // Always show overview

    final streakData = widget.response.streakData;
    if (streakData != null && streakData['hasStreakIncreased'] == true) {
      _previousStreak = streakData['previousStreak'] as int?;
      _currentStreak = streakData['currentStreak'] as int?;
      if (_currentStreak != null) {
        _steps.add(PostLessonStep.streak);
      }
    }

    for (final reward in widget.response.rewards) {
      final type = reward.type.toLowerCase();
      if (type == 'gems' || type == 'gem') _totalGems += reward.amount;
      if (type == 'coins' || type == 'coin') _totalCoins += reward.amount;
    }

    if (_totalGems > 0 || _totalCoins > 0) {
      _steps.add(PostLessonStep.rewards);
    }

    // Init animations for Overview
    _overviewAnimController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 1500)
    );
    
    int xp = widget.response.xpEarned;
    int acc = ((widget.response.correctExercises / math.max(1, widget.response.totalExercises)) * 100).round();
    
    _expAnimation = IntTween(begin: 0, end: xp).animate(
      CurvedAnimation(parent: _overviewAnimController, curve: Curves.easeOutCubic)
    );
    _accuracyAnimation = IntTween(begin: 0, end: acc).animate(
      CurvedAnimation(parent: _overviewAnimController, curve: Curves.easeOutCubic)
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _overviewAnimController.forward();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _overviewAnimController.dispose();
    _removeCoinsOverlay();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStepIndex < _steps.length - 1) {
      setState(() {
        _currentStepIndex++;
      });
      // Reset animations if needed
      if (_steps[_currentStepIndex] == PostLessonStep.overview) {
        _overviewAnimController.forward(from: 0);
      }
    } else {
      Navigator.of(context).pop(true);
    }
  }

  void _showFlyingCoins() {
    if (_coinsOverlay != null) return;
    
    final RenderBox? chestBox = _chestKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? walletBox = _walletKey.currentContext?.findRenderObject() as RenderBox?;
    
    if (chestBox == null || walletBox == null) return;
    
    final startPos = chestBox.localToGlobal(Offset(chestBox.size.width / 2, chestBox.size.height / 2));
    final endPos = walletBox.localToGlobal(Offset(walletBox.size.width / 2, walletBox.size.height / 2));

    _coinsOverlay = OverlayEntry(
      builder: (context) {
        return FlyingCoinsAnimation(
          startPos: startPos,
          endPos: endPos,
          itemCount: 15,
          isGem: _totalGems > _totalCoins,
          onComplete: () {
            _removeCoinsOverlay();
          },
        );
      }
    );
    Overlay.of(context).insert(_coinsOverlay!);
  }

  void _removeCoinsOverlay() {
    _coinsOverlay?.remove();
    _coinsOverlay = null;
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStepIndex];
    final isDark = AppPreferences().isDarkMode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox.expand(
        child: Stack(
          children: [
            // 1. Cinematic Background
            Positioned.fill(
              child: AuroraMapBackground(
              scrollController: _scrollController,
              sectionColor: AppColors.macaw,
              sectionShadowColor: AppColors.primary,
            ),
          ),
          
          // Fake Wallet for coins to fly to
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: FadeInDown(
              child: Container(
                key: _walletKey,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.black : Colors.white).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Image.asset('assets/icons/coin.png', width: 24, height: 24),
                    const SizedBox(width: 8),
                    Text('Ví', style: TextStyle(color: Colors.amber.shade600, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),

          // 2. Content
          Positioned.fill(
            child: SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.2), 
                      end: Offset.zero
                    ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<PostLessonStep>(step),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: _buildCurrentStep(step, isDark),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.snow,
          border: Border(
            top: BorderSide(
              color: AppColors.swan,
              width: 1.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: AppButton(
            label: 'Tiếp tục',
            onPressed: () {
              if (step == PostLessonStep.rewards) {
                _showFlyingCoins();
                Future.delayed(const Duration(milliseconds: 1500), () {
                  if (mounted) _nextStep();
                });
              } else {
                _nextStep();
              }
            },
            variant: ButtonVariant.primary,
            size: ButtonSize.large,
            width: double.infinity,
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildCurrentStep(PostLessonStep step, bool isDark) {
    switch (step) {
      case PostLessonStep.overview:
        return _buildOverviewStep(isDark);
      case PostLessonStep.streak:
        return _buildStreakStep(isDark);
      case PostLessonStep.rewards:
        return _buildRewardsStep(isDark);
    }
  }

  Widget _buildOverviewStep(bool isDark) {
    String formatDuration(Duration? d) {
      if (d == null) return "00:00";
      String twoDigits(int n) => n.toString().padLeft(2, "0");
      String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
      return "$twoDigitMinutes:$twoDigitSeconds";
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'HOÀN THÀNH!',
          style: AppTypography.defaultTextTheme(isDark ? Colors.white : AppColors.bodyText).headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: Colors.amber,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 32),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: (isDark ? Colors.black : Colors.white).withOpacity(0.4),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: _overviewAnimController,
                builder: (context, child) {
                  return Column(
                    children: [
                      _buildStatRow('Tỉ lệ chính xác', '${_accuracyAnimation.value}%', Icons.track_changes, AppColors.macaw),
                      const SizedBox(height: 24),
                      _buildStatRow('EXP nhận được', '+${_expAnimation.value}', Icons.star, Colors.amber),
                      const SizedBox(height: 24),
                      _buildStatRow('Thời gian', formatDuration(widget.completionTime), Icons.timer, AppColors.primary),
                    ],
                  );
                }
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    final isDark = AppPreferences().isDarkMode;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.bodyText)),
          ],
        ),
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }

  Widget _buildStreakStep(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'STREAK LÊN HÌNH!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.orange, letterSpacing: 1),
        ),
        const SizedBox(height: 32),
        // Simple Flame
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.orange.withOpacity(0.5), blurRadius: 40, spreadRadius: 10),
            ],
          ),
          child: const Icon(Icons.local_fire_department, size: 100, color: Colors.orange),
        ),
        const SizedBox(height: 24),
        Text(
          '$_currentStreak Ngày',
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildRewardsStep(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'PHẦN THƯỞNG!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.amber, letterSpacing: 1),
        ),
        const SizedBox(height: 40),
        BounceInDown(
          child: Container(
            key: _chestKey,
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.amber.withOpacity(0.4), blurRadius: 30, spreadRadius: 5),
              ]
            ),
            child: Center(
              child: Image.asset('assets/icons/treasure_chest.png', width: 80, height: 80, errorBuilder: (c, e, s) => const Icon(Icons.card_giftcard, size: 80, color: Colors.amber)),
            ),
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_totalGems > 0) ...[
              Text('+$_totalGems', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.blue)),
              const SizedBox(width: 8),
              Image.asset('assets/icons/gem.png', width: 32, height: 32),
              const SizedBox(width: 24),
            ],
            if (_totalCoins > 0) ...[
              Text('+$_totalCoins', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.amber)),
              const SizedBox(width: 8),
              Image.asset('assets/icons/coin.png', width: 32, height: 32),
            ],
          ],
        )
      ],
    );
  }
}

// ----------------------------------------------------
// FLYING COINS ANIMATION
// ----------------------------------------------------
class FlyingCoinsAnimation extends StatefulWidget {
  final Offset startPos;
  final Offset endPos;
  final int itemCount;
  final bool isGem;
  final VoidCallback onComplete;

  const FlyingCoinsAnimation({
    super.key,
    required this.startPos,
    required this.endPos,
    this.itemCount = 10,
    this.isGem = false,
    required this.onComplete,
  });

  @override
  State<FlyingCoinsAnimation> createState() => _FlyingCoinsAnimationState();
}

class _FlyingCoinsAnimationState extends State<FlyingCoinsAnimation> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _animations;
  late List<Animation<double>> _scales;

  @override
  void initState() {
    super.initState();
    _controllers = [];
    _animations = [];
    _scales = [];

    final random = math.Random();

    for (int i = 0; i < widget.itemCount; i++) {
      final ctrl = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 600 + random.nextInt(400)),
      );
      _controllers.add(ctrl);

      // Random explosion offset
      final explodeX = widget.startPos.dx + (random.nextDouble() * 200 - 100);
      final explodeY = widget.startPos.dy + (random.nextDouble() * 200 - 100);
      
      final explodeOffset = Offset(explodeX, explodeY);

      final moveAnim = TweenSequence<Offset>([
        TweenSequenceItem(
          tween: Tween<Offset>(begin: widget.startPos, end: explodeOffset)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
          weight: 30,
        ),
        TweenSequenceItem(
          tween: Tween<Offset>(begin: explodeOffset, end: widget.endPos)
            .chain(CurveTween(curve: Curves.easeInBack)),
          weight: 70,
        ),
      ]).animate(ctrl);

      final scaleAnim = TweenSequence<double>([
        TweenSequenceItem(tween: Tween<double>(begin: 0, end: 1.5).chain(CurveTween(curve: Curves.easeOut)), weight: 20),
        TweenSequenceItem(tween: Tween<double>(begin: 1.5, end: 1.0), weight: 60),
        TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.2).chain(CurveTween(curve: Curves.easeIn)), weight: 20),
      ]).animate(ctrl);

      _animations.add(moveAnim);
      _scales.add(scaleAnim);

      // Start with a small random delay
      Future.delayed(Duration(milliseconds: i * 50), () {
        if (mounted) ctrl.forward();
      });
    }

    // Call onComplete when the last controller finishes
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.itemCount, (index) {
        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            if (!_controllers[index].isAnimating && !_controllers[index].isCompleted) return const SizedBox.shrink();
            
            return Positioned(
              left: _animations[index].value.dx - 16,
              top: _animations[index].value.dy - 16,
              child: Transform.scale(
                scale: _scales[index].value,
                child: Image.asset(
                  widget.isGem ? 'assets/icons/gem.png' : 'assets/icons/coin.png',
                  width: 32,
                  height: 32,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
