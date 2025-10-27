import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'energy_dropdown_tokens.dart';
// import 'dart:math'; // Cần cho icon gradient (unused)
import '../blocs/energy_bloc.dart';

// --- Định nghĩa màu sắc mới dựa trên ảnh chụp màn hình (Light Mode) ---
const Color _heartRed = Color(0xFFEA2B2B); // Giống AppColors.tomato
const Color _heartRedLight = Color(
  0xFFFFDDE5,
); // Giống AppList.incorrectRedLight
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
    Key? key,
    required this.currentHearts,
    required this.maxHearts,
    required this.timeUntilNextRecharge,
    required this.gemCostPerEnergy,
    required this.coinCostPerEnergy,
    required this.gemsBalance,
    required this.coinsBalance,
    this.onClose,
    this.useSpeechBubble = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget content = Column(
      // Căn giữa theo chiều ngang
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min, // Co lại vừa đủ
      children: [
        // 1. Tiêu đề "Trái tim"
        const Text(
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
        const SizedBox(height: 24),

        // 3. Text đếm ngược
        Text.rich(
          TextSpan(
            style: const TextStyle(
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
        const Text(
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
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    // This action could navigate to subscription flow; placeholder
                    // For now close overlay if provided
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
                      Navigator.pushNamed(
                        context,
                        '/exercise',
                        arguments: {'lessonId': 'review', 'lessonTitle': 'Ôn tập'},
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
                  onPressed: () {
                    // If disabled, AppButton will ignore taps. Keep handler idempotent.
                    if (energyNeeded <= 0) return;
                    if (canAffordGems) {
                      context.read<EnergyBloc>().add(
                        BuyEnergyEvent(
                          energyAmount: energyNeeded,
                          paymentMethod: 'GEMS',
                        ),
                      );
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
                  onPressed: () {
                    if (energyNeeded <= 0) return;
                    if (canAffordCoins) {
                      context.read<EnergyBloc>().add(
                        BuyEnergyEvent(
                          energyAmount: energyNeeded,
                          paymentMethod: 'COINS',
                        ),
                      );
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

    if (useSpeechBubble) {
      return content;
    }

    return Container(
      color: AppColors.snow, // Nền trắng
      padding: const EdgeInsets.symmetric(
        horizontal: EnergyDropdownTokens.horizontalPadding,
        vertical: EnergyDropdownTokens.verticalPadding,
      ),
      child: content,
    );
  }
}

// --- WIDGET CON ĐỂ HIỂN THỊ CÁC TRÁI TIM ---
class _HeartDisplay extends StatelessWidget {
  final int currentHearts;
  final int maxHearts;

  const _HeartDisplay({
    Key? key,
    required this.currentHearts,
    this.maxHearts = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxHearts, (index) {
        bool isFilled = index < currentHearts;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Icon(
            Icons.favorite,
            color: isFilled ? _heartRed : _heartRedLight,
            size: EnergyDropdownTokens.heartIconSize,
          ),
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
    Key? key,
    required this.title,
    required this.icon,
    required this.onPressed,
    this.ctaText,
    this.price,
    this.isDisabled = false,
    this.priceIconAsset,
  }) : super(key: key);

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
            // Use large size so the button height comfortably contains icon + text
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
                      style: const TextStyle(
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
