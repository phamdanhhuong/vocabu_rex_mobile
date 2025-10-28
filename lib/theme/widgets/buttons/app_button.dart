import 'package:flutter/material.dart';
import 'dart:math';
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
  })  : assert(label != null || child != null, 'Provide label or child'),
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
      case ButtonVariant.outline:
        return AppColors.snow; // Nền trắng (giống background)
      case ButtonVariant.destructive:
        return AppColors.cardinal;
      case ButtonVariant.highlight: // Đã đổi tên
        return AppColors.bee;
      case ButtonVariant.alternate: // Đã đổi tên
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
        return AppColors.tomato; // Sửa lỗi tham chiếu màu
      case ButtonVariant.highlight: // Đã đổi tên
        return AppColors.fox;
      case ButtonVariant.alternate: // Đã đổi tên
        return AppColors.humpback;
      case ButtonVariant.ghost:
        return Colors.transparent;
      case ButtonVariant.outline:
        return AppColors.hare;
    }
  }

  Color get _textColor {
    if (isDisabled) {
      return AppColors.hare; // Chữ xám nhạt khi bị vô hiệu hóa
    }

    switch (variant) {
      case ButtonVariant.ghost:
      case ButtonVariant.outline:
        return AppColors.primary; // Chữ màu xanh lá

      default:
        return AppColors.onPrimary; // Chữ màu trắng
    }
  }

  BorderSide get _borderSide {
    if (isDisabled) {
      return BorderSide.none;
    }
    if (variant == ButtonVariant.outline) {
      return const BorderSide(
        color: AppColors.swan,
        width: 1.0,
      );
    }
    return BorderSide.none;
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
    final effectiveOnPressed = (isDisabled || isLoading) ? null : onPressed;

    final buttonLabel = isLoading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: _textColor),
          )
        : (child ?? Text(label!, style: _textStyle));

    return GestureDetector(
      onTap: effectiveOnPressed,
      behavior: HitTestBehavior.opaque,
      child: LayoutBuilder(builder: (context, constraints) {
        // Resolve width in a safe way: if caller passed double.infinity or
        // parent constraints are unbounded, fall back to a sensible default.
        final maxConstraint = constraints.maxWidth;
        final bool parentHasBoundedWidth = maxConstraint.isFinite;

        double effectiveWidth;
        if (width != null) {
          if (width!.isInfinite) {
            effectiveWidth = parentHasBoundedWidth ? maxConstraint : AppButtonTokens.defaultWidth;
          } else {
            effectiveWidth = width!;
          }
        } else {
          // no width provided -> use defaultWidth but if parent width is smaller,
          // allow the defaultWidth to be capped by parent.
          effectiveWidth = parentHasBoundedWidth ? min(AppButtonTokens.defaultWidth, maxConstraint) : AppButtonTokens.defaultWidth;
        }

        return Column(
          children: [
            Container(
              width: effectiveWidth,
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
                      width: effectiveWidth,
                      height: _backgroundHeight,
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: _backgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppButtonTokens.borderRadius,
                          ),
                          side: _borderSide,
                        ),
                        shadows: [
                          BoxShadow(
                            color: _shadowColor,
                            blurRadius: 0,
                            offset: const Offset(0, 4),
                            spreadRadius: 0,
                          )
                        ],
                      ),
                    ),
                  ),
                  Align(alignment: Alignment.center, child: buttonLabel),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

// Đã cập nhật enum
enum ButtonVariant {
  primary,
  secondary,
  ghost,
  destructive,
  highlight,
  alternate,
  outline
}

enum ButtonSize { small, medium, large }

