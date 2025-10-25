import 'package:flutter/material.dart';
import '../../colors.dart';
import 'app_button_tokens.dart';

/// Reusable app button used across the app.
///
/// Variants: primary, secondary, ghost, destructive, bee, macaw
/// Sizes: small, medium, large
class AppButton extends StatelessWidget {
  final String? label;
  final Widget? child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final ButtonVariant variant;
  final ButtonSize size;
  final double? width; // null = wrap / expand as allowed
  final double? fontSize;

  const AppButton({
    Key? key,
    this.label,
    this.child,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.width,
    this.fontSize,
  }) : assert(label != null || child != null, 'Provide label or child'),
       super(key: key);

  double get _height {
    switch (size) {
      case ButtonSize.small:
        return 40;
      case ButtonSize.large:
        return 56;
      case ButtonSize.medium:
        return 50;
    }
  }

  double get _backgroundHeight {
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.large:
        return 52;
      case ButtonSize.medium:
        return 46;
    }
  }

  Color get _backgroundColor {
    if (isDisabled) {
      return AppColors.swan; // Nền xám nhạt khi bị vô hiệu hóa
    }

    switch (variant) {
      case ButtonVariant.secondary:
        return AppColors.primaryVariant;
      case ButtonVariant.ghost:
        return Colors.transparent; // Nền trong suốt
      case ButtonVariant.destructive:
        return AppColors.cardinal;
      case ButtonVariant.bee:
        return AppColors.bee;
      case ButtonVariant.macaw:
        return AppColors.macaw;
      case ButtonVariant.primary:
        return AppColors.primary;
    }
  }

  Color get _shadowColor {
    if (isDisabled) {
      return Colors.transparent;
    }
    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.wingOverlay;
      case ButtonVariant.secondary:
        return AppColors.primary;
      case ButtonVariant.destructive:
        return AppColors.beakInner;
      case ButtonVariant.bee:
        return AppColors.fox;
      case ButtonVariant.macaw:
        return AppColors.humpback;
      case ButtonVariant.ghost:
        return Colors.transparent; // Ghost không có bóng
    }
  }

  Color get _textColor {
    if (isDisabled) {
      return AppColors
          .hare; // Chữ xám nhạt (nhạt hơn bodyText) khi bị vô hiệu hóa
    }

    switch (variant) {
      // TRẢ LẠI NHƯ CŨ
      case ButtonVariant.ghost:
        return AppColors.primary; // Chữ màu xanh lá

      default:
        return AppColors.onPrimary; // Chữ màu trắng
    }
  }

  TextStyle get _textStyle {
    final size = fontSize ?? AppButtonTokens.fontSize;
    return TextStyle(
      fontFamily: AppButtonTokens.fontFamily,
      fontWeight: AppButtonTokens.fontWeight,
      fontSize: size,
      height: AppButtonTokens.lineHeight,
      letterSpacing: AppButtonTokens.letterSpacing,
      color: _textColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Logic này đã đúng, nó tắt việc nhấn nút
    final effectiveOnPressed = (isDisabled || isLoading) ? null : onPressed;

    final buttonLabel = isLoading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: _textColor),
          )
        : (child ?? Text(label!, style: _textStyle));

    // Dùng `Opacity` để làm mờ nút khi loading (nhưng vẫn giữ kích thước)
    // Hoặc giữ nguyên nếu bạn không muốn hiệu ứng này
    return GestureDetector(
      onTap: effectiveOnPressed,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Container(
            width: width ?? AppButtonTokens.defaultWidth,
            height: _height,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppButtonTokens.borderRadius,
                ),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    width: width ?? AppButtonTokens.defaultWidth,
                    height: _backgroundHeight,
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: _backgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppButtonTokens.borderRadius,
                        ),
                      ),
                      shadows: [
                        BoxShadow(
                          color: _shadowColor,
                          blurRadius: 0,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ),
                // Center label horizontally and vertically
                Align(alignment: Alignment.center, child: buttonLabel),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Các enum này không đổi
enum ButtonVariant { primary, secondary, ghost, destructive, bee, macaw }

enum ButtonSize { small, medium, large }
