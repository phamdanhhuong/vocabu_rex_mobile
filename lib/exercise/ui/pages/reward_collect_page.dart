import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'dart:math' as math;

class RewardCollectPage extends StatefulWidget {
  final int gems;
  final int coins;

  const RewardCollectPage({
    super.key,
    required this.gems,
    required this.coins,
  });

  @override
  State<RewardCollectPage> createState() => _RewardCollectPageState();
}

class _RewardCollectPageState extends State<RewardCollectPage>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late AnimationController _openController;
  late AnimationController _coinController;
  
  bool _isOpened = false;
  bool _showRewards = false;
  List<CoinParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    
    // Animation lắc rương
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    
    // Animation mở rương
    _openController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Animation coins bay ra
    _coinController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _coinController.addStatusListener((status) {
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
    _coinController.dispose();
    super.dispose();
  }

  void _onChestTapped() {
    if (_isOpened) return;
    
    setState(() {
      _isOpened = true;
    });
    
    _shakeController.stop();
    _openController.forward();
    
    // Tạo particles
    Future.delayed(const Duration(milliseconds: 300), () {
      _createParticles();
      _coinController.forward();
    });
  }

  void _createParticles() {
    final random = math.Random();
    final bool hasGems = widget.gems > 0;
    final bool hasCoins = widget.coins > 0;
    
    setState(() {
      _particles = List.generate(15, (index) {
        final isGem = hasGems && (index % 2 == 0 || !hasCoins);
        return CoinParticle(
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

  @override
  Widget build(BuildContext context) {
    // Xác định loại phần thưởng chính để hiển thị màu và text phù hợp
    final bool isGemReward = widget.gems > 0;
    final int rewardValue = isGemReward ? widget.gems : widget.coins;
    final String rewardName = isGemReward ? "đá quý" : "xu";
    final Color highlightColor = isGemReward ? AppColors.macaw : AppColors.bee;

    return Scaffold(
      backgroundColor: AppColors.snow,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 1. TOP BAR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.diamond_rounded, color: AppColors.macaw, size: 24),
                      SizedBox(width: 4),
                      Text(
                        '550',
                        style: TextStyle(
                          color: AppColors.macaw,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 2. CHEST WITH ANIMATION
                      GestureDetector(
                        onTap: _onChestTapped,
                        child: AnimatedBuilder(
                          animation: _shakeController,
                          builder: (context, child) {
                            final shakeValue = _isOpened ? 0.0 : math.sin(_shakeController.value * 2 * math.pi) * 0.05;
                            return Transform.rotate(
                              angle: shakeValue,
                              child: ScaleTransition(
                                scale: Tween<double>(begin: 1.0, end: 1.2).animate(
                                  CurvedAnimation(parent: _openController, curve: Curves.easeOut),
                                ),
                                child: Container(
                                  height: 200,
                                  width: 200,
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    _isOpened ? 'assets/icons/reward_chest_open.png' : 'assets/icons/reward_chest_closed.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        _isOpened ? Icons.inventory_rounded : Icons.inbox_rounded,
                                        size: 120,
                                        color: AppColors.bee,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      SizedBox(height: 32),

                      // 3. TEXT (Chỉ hiện sau khi mở rương)
                      AnimatedOpacity(
                        opacity: _showRewards ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 500),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: RichText(
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
                                TextSpan(text: 'Bạn đã hoàn thành một Nhiệm vụ hằng ngày và kiếm được '),
                                TextSpan(
                                  text: '$rewardValue $rewardName!',
                                  style: TextStyle(
                                    color: highlightColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 4. BUTTON (Chỉ hiện sau khi mở rương)
                AnimatedOpacity(
                  opacity: _showRewards ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
                    child: AppButton(
                      label: 'TIẾP TỤC',
                      backgroundColor: AppColors.macaw,
                      shadowColor: AppColors.humpback,
                      onPressed: _showRewards ? () {
                        Navigator.of(context).pop(true);
                      } : null,
                      width: double.infinity,
                    ),
                  ),
                ),
              ],
            ),
            
            // 5. COIN/GEM PARTICLES
            ..._particles.map((particle) => AnimatedBuilder(
              animation: _coinController,
              builder: (context, child) {
                final progress = Curves.easeOut.transform(
                  math.max(0.0, math.min(1.0, (_coinController.value * 1000 - particle.delay) / 1000))
                );
                
                final x = particle.initialX + particle.targetX * progress;
                final y = particle.initialY + particle.targetY * progress - 50 * progress * (1 - progress) * 4;
                final opacity = progress < 0.8 ? 1.0 : (1 - (progress - 0.8) / 0.2);
                
                return Positioned(
                  left: MediaQuery.of(context).size.width / 2 + x,
                  top: MediaQuery.of(context).size.height / 2 + y,
                  child: Opacity(
                    opacity: opacity,
                    child: Icon(
                      particle.isGem ? Icons.diamond : Icons.monetization_on,
                      color: particle.isGem ? AppColors.macaw : AppColors.bee,
                      size: 30,
                    ),
                  ),
                );
              },
            )),
          ],
        ),
      ),
    );
  }
}

class CoinParticle {
  final bool isGem;
  final double initialX;
  final double initialY;
  final double targetX;
  final double targetY;
  final int delay;

  CoinParticle({
    required this.isGem,
    required this.initialX,
    required this.initialY,
    required this.targetX,
    required this.targetY,
    required this.delay,
  });
}