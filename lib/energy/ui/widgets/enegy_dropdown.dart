import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'energy_dropdown_tokens.dart';
// import 'dart:math'; // Cần cho icon gradient (unused)
import '../blocs/energy_bloc.dart';
import 'package:vocabu_rex_mobile/currency/ui/blocs/currency_bloc.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';

// --- Định nghĩa màu sắc mới dựa trên ảnh chụp màn hình (Light Mode) ---
const Color _heartRed = Color(0xFFEA2B2B); // Giống AppColors.tomato
Color get _heartRedLight => AppPreferences().isDarkMode ? const Color(0xFF4B1D2A) : const Color(0xFFFFDDE5);
// _heartGrayBorder removed (unused)
const Color _gemPriceColor = Color(0xFF1CB0F6); // Giống AppColors.macaw

// Màu cho nút Gradient
const Color _gradientBlue = Color(0xFF3892F3);
const Color _gradientPurple = Color(0xFFAD52F2);

/// Giao diện modal "Trái tim", dựa trên ảnh chụp màn hình (chế độ sáng).
class HeartsView extends StatelessWidget {
  final int currentHearts;
  final int maxHearts;
  final String timeUntilNextRecharge;
  final int gemCostPerEnergy;
  final int coinCostPerEnergy;
  final int gemsBalance;
  final int coinsBalance;
  final VoidCallback? onClose;
  final bool useSpeechBubble;

  const HeartsView({
    super.key,
    required this.currentHearts,
    required this.maxHearts,
    required this.timeUntilNextRecharge,
    required this.gemCostPerEnergy,
    required this.coinCostPerEnergy,
    required this.gemsBalance,
    required this.coinsBalance,
    this.onClose,
    this.useSpeechBubble = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = Column(
      // Căn giữa theo chiều ngang
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min, // Co lại vừa đủ
      children: [
        // 1. Tiêu đề "Trái tim"
        Text(
          'Trái tim',
          style: TextStyle(
            color: AppColors.bodyText,
            fontSize: EnergyDropdownTokens.titleFontSize,
            fontWeight: FontWeight.bold,
            fontFamily: 'DuolingoFeather',
          ),
        ),
        const SizedBox(height: 24),

        // 2. Hiển thị 5 trái tim
        _HeartDisplay(currentHearts: currentHearts, maxHearts: maxHearts),
        const SizedBox(height: 12),
        // Progress Bar (Liquid Energy)
        if (currentHearts < maxHearts) ...[
          Container(
            width: 150,
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: AppColors.wolf.withOpacity(0.3),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Shimmer.fromColors(
                baseColor: _heartRed,
                highlightColor: Colors.yellowAccent,
                period: const Duration(seconds: 2),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: _heartRed,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // 3. Text đếm ngược
        Text.rich(
          TextSpan(
            style: TextStyle(
              color: AppColors.bodyText,
              fontSize: EnergyDropdownTokens.bodyFontSize,
              fontFamily: 'DuolingoFeather',
            ),
            children: [
              const TextSpan(text: 'Trái tim tiếp theo sẽ có sau '),
              TextSpan(
                text: '5 tiếng',
                style: const TextStyle(
                  color: _heartRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // 4. Text phụ
        Text(
          'Bạn vẫn còn trái tim! Học tiếp nào',
          style: TextStyle(
            color: AppColors.wolf, // Xám nhạt hơn
            fontSize: EnergyDropdownTokens.bodyFontSize,
            fontFamily: 'DuolingoFeather',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: EnergyDropdownTokens.sectionSpacing),

        // 5. Ba nút tùy chọn
        // Compute energy needed and costs
        Builder(
          builder: (context) {
            final energyNeeded = maxHearts - currentHearts;
            final gemsNeeded = energyNeeded * gemCostPerEnergy;
            final coinsNeeded = energyNeeded * coinCostPerEnergy;
            final canAffordGems = gemsBalance >= gemsNeeded && energyNeeded > 0;
            final canAffordCoins =
                coinsBalance >= coinsNeeded && energyNeeded > 0;

            // Precompute full/refill prices and display prices so we can show
            // a meaningful non-zero price even when energy is full.
            final int fullGemsPrice = maxHearts * gemCostPerEnergy;
            final int fullCoinsPrice = maxHearts * coinCostPerEnergy;
            final int displayGemsPrice = energyNeeded > 0
                ? gemsNeeded
                : fullGemsPrice;
            final int displayCoinsPrice = energyNeeded > 0
                ? coinsNeeded
                : fullCoinsPrice;

            return Column(
              children: [
                _HeartOptionButton(
                  title: 'TRÁI TIM VÔ HẠN',
                  ctaText: 'THỬ MIỄN PHÍ',
                  icon: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [_gradientBlue, _gradientPurple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Icon(
                      Icons.all_inclusive,
                      size: EnergyDropdownTokens.optionIconSize,
                      color: AppColors.white,
                    ),
                  ),
                  onPressed: () {
                    onClose?.call();
                  },
                ),
                const SizedBox(height: EnergyDropdownTokens.itemSpacing),
                // New option: ÔN TẬP (Practice) - opens practice flow or closes overlay
                _HeartOptionButton(
                  title: 'ÔN TẬP',
                  icon: Image.asset(
                    'assets/icons/full_fill_heart.png',
                    width: EnergyDropdownTokens.optionIconSize,
                    height: EnergyDropdownTokens.optionIconSize,
                    fit: BoxFit.contain,
                  ),
                  onPressed: () {
                    // Close the overlay first, then navigate to review screen.
                    onClose?.call();
                    Future.microtask(() {
                      if (!context.mounted) return;
                      Navigator.pushNamed(
                        context,
                        '/exercise',
                        arguments: {
                          'lessonId': 'review',
                          'lessonTitle': 'Ôn tập',
                          'isPronun': false,
                        },
                      );
                    });
                  },
                ),
                const SizedBox(height: EnergyDropdownTokens.itemSpacing),

                // Recovery options are always shown, but disabled when energy is full.
                _HeartOptionButton(
                  title: 'HỒI PHỤC TRÁI TIM (Gems)',
                  price: displayGemsPrice,
                  isDisabled: energyNeeded == 0,
                  priceIconAsset: 'assets/icons/gem.png',
                  icon: Image.asset(
                    'assets/icons/heart.png',
                    width: EnergyDropdownTokens.optionIconSize,
                    height: EnergyDropdownTokens.optionIconSize,
                    fit: BoxFit.contain,
                  ),
                  onPressed: () async {
                    // If disabled, AppButton will ignore taps. Keep handler idempotent.
                    if (energyNeeded <= 0) return;
                    if (canAffordGems) {
                      context.read<EnergyBloc>().add(
                        BuyEnergyEvent(
                          energyAmount: energyNeeded,
                          paymentMethod: 'GEMS',
                        ),
                      );
                      // Wait for purchase to complete, then refresh
                      await Future.delayed(const Duration(milliseconds: 500));
                      if (context.mounted) {
                        context.read<CurrencyBloc>().add(
                          GetCurrencyBalanceEvent(''),
                        );
                        context.read<EnergyBloc>().add(GetEnergyStatusEvent());
                      }
                      onClose?.call();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Không đủ Gem để mua năng lượng'),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: EnergyDropdownTokens.itemSpacing),
                _HeartOptionButton(
                  title: 'HỒI PHỤC TRÁI TIM (Coins)',
                  price: displayCoinsPrice,
                  isDisabled: energyNeeded == 0,
                  priceIconAsset: 'assets/icons/coin.png',
                  icon: Image.asset(
                    'assets/icons/in_charged_heart.png',
                    width: EnergyDropdownTokens.optionIconSize,
                    height: EnergyDropdownTokens.optionIconSize,
                    fit: BoxFit.contain,
                  ),
                  onPressed: () async {
                    if (energyNeeded <= 0) return;
                    if (canAffordCoins) {
                      context.read<EnergyBloc>().add(
                        BuyEnergyEvent(
                          energyAmount: energyNeeded,
                          paymentMethod: 'COINS',
                        ),
                      );
                      // Wait for purchase to complete, then refresh
                      await Future.delayed(const Duration(milliseconds: 500));
                      if (context.mounted) {
                        context.read<CurrencyBloc>().add(
                          GetCurrencyBalanceEvent(''),
                        );
                        context.read<EnergyBloc>().add(GetEnergyStatusEvent());
                      }
                      onClose?.call();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Không đủ Coin để mua năng lượng'),
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        ),
      ],
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassColor = isDark ? Colors.black.withOpacity(0.85) : Colors.white.withOpacity(0.95);
    
    Color glowColor;
    if (currentHearts == 0) {
      glowColor = _heartRed.withOpacity(0.5);
    } else if (currentHearts >= maxHearts) {
      glowColor = Colors.blue.withOpacity(0.5);
    } else {
      glowColor = Colors.black.withOpacity(0.1);
    }

    return Container(
      decoration: BoxDecoration(
        color: glassColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: currentHearts == 0 ? _heartRed : (isDark ? Colors.white24 : Colors.white), 
          width: 2
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: 20,
            spreadRadius: currentHearts == 0 || currentHearts >= maxHearts ? 5 : 0,
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: EnergyDropdownTokens.horizontalPadding,
        vertical: EnergyDropdownTokens.verticalPadding,
      ),
      child: content,
    );
  }
}

// --- WIDGET CON ĐỂ HIỂN THỊ CÁC TRÁI TIM ---
class _HeartDisplay extends StatefulWidget {
  final int currentHearts;
  final int maxHearts;

  const _HeartDisplay({required this.currentHearts, this.maxHearts = 5});

  @override
  State<_HeartDisplay> createState() => _HeartDisplayState();
}

class _HeartDisplayState extends State<_HeartDisplay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    // Subtle pulse scale: 1.0 to 1.15
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.maxHearts, (index) {
        bool isFilled = index < widget.currentHearts;
        Widget heartIcon = Icon(
          Icons.favorite,
          color: isFilled ? _heartRed : _heartRedLight,
          size: EnergyDropdownTokens.heartIconSize,
        );

        // Apply subtle pulse only to the rightmost heart
        if (index == widget.maxHearts - 1) {
          heartIcon = ScaleTransition(
            scale: _scaleAnimation,
            child: heartIcon,
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: heartIcon,
        );
      }),
    );
  }
}

// --- WIDGET CON CHO CÁC NÚT TÙY CHỌN ---
class _HeartOptionButton extends StatelessWidget {
  final String title;
  final Widget icon;
  final VoidCallback onPressed;
  final String? ctaText;
  final int? price;
  final bool isDisabled;
  final String? priceIconAsset;

  const _HeartOptionButton({
    required this.title,
    required this.icon,
    required this.onPressed,
    this.ctaText,
    this.price,
    this.isDisabled = false,
    this.priceIconAsset,
  });

  @override
  Widget build(BuildContext context) {
    Widget trailingWidget;
    if (ctaText != null) {
      // Nút "Thử miễn phí" với gradient text
      trailingWidget = ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [_gradientBlue, _gradientPurple],
        ).createShader(bounds),
        child: Text(
          ctaText!,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: EnergyDropdownTokens.bodyFontSize,
          ),
        ),
      );
    } else if (price != null) {
      // Nút "Hồi phục" (có giá)
      trailingWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (priceIconAsset != null) ...[
            Image.asset(
              priceIconAsset!,
              width: EnergyDropdownTokens.gemPriceIconSize,
              height: EnergyDropdownTokens.gemPriceIconSize,
              fit: BoxFit.contain,
            ),
          ] else ...[
            const Icon(
              Icons.diamond,
              color: _gemPriceColor,
              size: EnergyDropdownTokens.gemPriceIconSize,
            ),
          ],
          const SizedBox(width: 4),
          Text(
            price.toString(),
            style: const TextStyle(
              color: _gemPriceColor,
              fontSize: EnergyDropdownTokens.bodyFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else {
      // Nút "Luyện tập" (không có gì)
      trailingWidget = const SizedBox();
    }

    // Measure the available width from the parent (overlay) and fill it while
    // preserving internal padding. If the parent doesn't provide a finite
    // constraint, fall back to a safe screen-based width.
    return LayoutBuilder(
      builder: (context, constraints) {
        double available = constraints.maxWidth;
        if (available.isInfinite || available <= 0) {
          final mq = MediaQuery.of(context);
          available =
              mq.size.width -
              (EnergyDropdownTokens.overlayHorizontalMargin * 2);
        }

        // We still wrap the AppButton in SizedBox to force it to the parent's
        // available width. The inner Padding keeps the visual spacing inside
        // the button.
        return SizedBox(
          width: available,
          child: AppButton(
            onPressed: onPressed,
            isDisabled: isDisabled,
            variant: ButtonVariant.outline,
            size: ButtonSize.large,
            width: available,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: EnergyDropdownTokens.buttonHorizontalPadding,
                vertical: EnergyDropdownTokens.buttonVerticalPadding,
              ),
              child: Row(
                children: [
                  icon,
                  const SizedBox(
                    width: EnergyDropdownTokens.buttonContentSpacing,
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: AppColors.bodyText,
                        fontSize: EnergyDropdownTokens.bodyFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  trailingWidget,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Gradient icon helper removed — dropdown now uses PNGs for gem/coin and inline ShaderMask for the trial icon.
