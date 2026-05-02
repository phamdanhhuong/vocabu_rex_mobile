import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/quest/domain/enums/quest_enums.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:vocabu_rex_mobile/web/widgets/centered_dialog_wrapper.dart';
import 'dart:math' as math;

class QuestRewardPage extends StatefulWidget {
  final String questName;
  final int rewardXp;
  final int rewardGems;
  final ChestType chestType;

  const QuestRewardPage({
    super.key,
    required this.questName,
    required this.rewardXp,
    required this.rewardGems,
    required this.chestType,
  });

  @override
  State<QuestRewardPage> createState() => _QuestRewardPageState();
}

class _QuestRewardPageState extends State<QuestRewardPage>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late AnimationController _openController;
  late AnimationController _particleController;

  bool _isOpened = false;
  bool _showRewards = false;
  List<_RewardParticle> _particles = [];

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _openController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _particleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showRewards = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _openController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _onChestTapped() {
    if (_isOpened) return;

    setState(() {
      _isOpened = true;
    });

    _shakeController.stop();
    _openController.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      _createParticles();
      _particleController.forward();
    });
  }

  void _createParticles() {
    final random = math.Random();
    final hasGems = widget.rewardGems > 0;
    final hasXp = widget.rewardXp > 0;

    setState(() {
      _particles = List.generate(15, (index) {
        final isGem = hasGems && (index % 2 == 0 || !hasXp);
        return _RewardParticle(
          isGem: isGem,
          initialX: 0,
          initialY: 0,
          targetX: (random.nextDouble() - 0.5) * 300,
          targetY: -100 - random.nextDouble() * 200,
          delay: index * 50,
        );
      });
    });
  }

  String _getChestImagePath(bool opened) {
    String typeName;
    switch (widget.chestType) {
      case ChestType.bronze:
        typeName = 'bronze';
      case ChestType.silver:
        typeName = 'silver';
      case ChestType.gold:
      case ChestType.legendary:
        typeName = 'gold'; // legendary fallback to gold
    }
    final state = opened ? 'open' : 'close';
    return 'assets/icons/chest_${typeName}_$state.png';
  }

  Color _getChestColor() {
    switch (widget.chestType) {
      case ChestType.bronze:
        return Colors.brown[600]!;
      case ChestType.silver:
        return Colors.grey[600]!;
      case ChestType.gold:
        return Colors.amber[700]!;
      case ChestType.legendary:
        return Colors.purple[700]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CenteredDialogWrapper(
      child: Scaffold(
        backgroundColor: AppColors.snow,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 48),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Chest with animation
                        GestureDetector(
                          onTap: _onChestTapped,
                          child: AnimatedBuilder(
                            animation: _shakeController,
                            builder: (context, child) {
                              final shakeValue = _isOpened
                                  ? 0.0
                                  : math.sin(
                                          _shakeController.value * 2 * math.pi,
                                        ) *
                                        0.05;
                              return Transform.rotate(
                                angle: shakeValue,
                                child: ScaleTransition(
                                  scale: Tween<double>(begin: 1.0, end: 1.2)
                                      .animate(
                                        CurvedAnimation(
                                          parent: _openController,
                                          curve: Curves.easeOut,
                                        ),
                                      ),
                                  child: Container(
                                    height: 200,
                                    width: 200,
                                    alignment: Alignment.center,
                                    child: Image.asset(
                                      _getChestImagePath(_isOpened),
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Icon(
                                              _isOpened
                                                  ? Icons.inventory_rounded
                                                  : Icons.inbox_rounded,
                                              size: 120,
                                              color: _getChestColor(),
                                            );
                                          },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Tap hint (before opening)
                        AnimatedOpacity(
                          opacity: _isOpened ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            'Chạm để mở rương!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Reward text (after opening)
                        AnimatedOpacity(
                          opacity: _showRewards ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 500),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: _buildRewardText(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Button (after opening)
                  AnimatedOpacity(
                    opacity: _showRewards ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 24,
                      ),
                      child: AppButton(
                        label: 'TIẾP TỤC',
                        backgroundColor: AppColors.macaw,
                        shadowColor: AppColors.humpback,
                        onPressed: _showRewards
                            ? () {
                                Navigator.of(context).pop(true);
                              }
                            : null,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ],
              ),

              // Particles
              ..._particles.map(
                (particle) => AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, child) {
                    final progress = Curves.easeOut.transform(
                      math.max(
                        0.0,
                        math.min(
                          1.0,
                          (_particleController.value * 1000 - particle.delay) /
                              1000,
                        ),
                      ),
                    );

                    final x = particle.initialX + particle.targetX * progress;
                    final y =
                        particle.initialY +
                        particle.targetY * progress -
                        50 * progress * (1 - progress) * 4;
                    final opacity = progress < 0.8
                        ? 1.0
                        : (1 - (progress - 0.8) / 0.2);

                    return Positioned(
                      left: MediaQuery.of(context).size.width / 2 + x,
                      top: MediaQuery.of(context).size.height / 2 + y,
                      child: Opacity(
                        opacity: opacity,
                        child: Icon(
                          particle.isGem ? Icons.diamond : Icons.stars,
                          color: particle.isGem
                              ? AppColors.macaw
                              : AppColors.bee,
                          size: 30,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardText() {
    final hasGems = widget.rewardGems > 0;
    final hasXp = widget.rewardXp > 0;

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontSize: 22,
          color: AppColors.eel,
          height: 1.4,
          fontWeight: FontWeight.bold,
          fontFamily: 'Nunito',
        ),
        children: [
          const TextSpan(text: 'Chúc mừng! Bạn đã hoàn thành nhiệm vụ '),
          TextSpan(
            text: '"${widget.questName}"',
            style: TextStyle(color: _getChestColor()),
          ),
          const TextSpan(text: ' và kiếm được '),
          if (hasXp)
            TextSpan(
              text: '${widget.rewardXp} XP',
              style: const TextStyle(color: AppColors.bee),
            ),
          if (hasXp && hasGems) const TextSpan(text: ' và '),
          if (hasGems)
            TextSpan(
              text: '${widget.rewardGems} đá quý',
              style: const TextStyle(color: AppColors.macaw),
            ),
          const TextSpan(text: '!'),
        ],
      ),
    );
  }
}

class _RewardParticle {
  final bool isGem;
  final double initialX;
  final double initialY;
  final double targetX;
  final double targetY;
  final int delay;

  _RewardParticle({
    required this.isGem,
    required this.initialX,
    required this.initialY,
    required this.targetX,
    required this.targetY,
    required this.delay,
  });
}
