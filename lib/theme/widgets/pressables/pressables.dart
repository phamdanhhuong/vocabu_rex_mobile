import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/tokens.dart';

/// Reusable pressable surfaces that mimic AppButton's press behavior.
/// Extracted to reduce `learning_map.dart` size and avoid duplication.

class PressableRounded extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  /// Optional explicit shadow color to use for the box shadow. If null,
  /// falls back to using backgroundColor.withAlpha(AppTokens.dividerAlpha).
  final Color? shadowColor;

  const PressableRounded({Key? key, required this.child, this.onTap, this.height, this.borderRadius, this.backgroundColor, this.shadowColor}) : super(key: key);

  @override
  State<PressableRounded> createState() => _PressableRoundedState();
}

class _PressableRoundedState extends State<PressableRounded> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails d) => setState(() => _isPressed = true);
  void _onTapUp(TapUpDetails d) {
    setState(() => _isPressed = false);
    Future.microtask(() => widget.onTap?.call());
  }

  void _onTapCancel() => setState(() => _isPressed = false);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedContainer(
        duration: AppTokens.pressAnimationDuration,
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _isPressed ? AppTokens.pressTranslation : 0.0, 0),
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? AppColors.white,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
          // Solid left-edge divider (use shadowColor when provided so the
          // header feels elevated in the section palette)
          border: Border(
            right: BorderSide(
              color: (widget.shadowColor ?? (widget.backgroundColor ?? AppColors.white).withAlpha(AppTokens.dividerAlpha)),
              width: AppTokens.dividerWidth,
            ),
          ),
          boxShadow: _isPressed
              ? null
              : [
                  BoxShadow(
                    color: widget.shadowColor ?? (widget.backgroundColor ?? AppColors.white).withAlpha(AppTokens.dividerAlpha),
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  )
                ],
        ),
        child: widget.child,
      ),
    );
  }
}

class PressableIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? iconColor;
  /// Optional explicit shadow color to use for the box shadow. If null,
  /// falls back to using backgroundColor.withAlpha(AppTokens.dividerAlpha).
  final Color? shadowColor;

  const PressableIconButton({Key? key, required this.icon, this.onTap, this.height, this.width, this.borderRadius, this.backgroundColor, this.iconColor, this.shadowColor}) : super(key: key);

  @override
  State<PressableIconButton> createState() => _PressableIconButtonState();
}

class _PressableIconButtonState extends State<PressableIconButton> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails d) => setState(() => _isPressed = true);
  void _onTapUp(TapUpDetails d) {
    setState(() => _isPressed = false);
    Future.microtask(() => widget.onTap?.call());
  }

  void _onTapCancel() => setState(() => _isPressed = false);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedContainer(
        duration: AppTokens.pressAnimationDuration,
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _isPressed ? AppTokens.pressTranslation : 0.0, 0),
        width: widget.width ?? AppTokens.headerButtonWidth,
        height: widget.height ?? AppTokens.headerHeight,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? AppColors.white,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
          // Solid right-edge divider (use shadowColor when provided)
          border: Border(
            left: BorderSide(
              color: (widget.shadowColor ?? (widget.backgroundColor ?? AppColors.white).withAlpha(AppTokens.dividerAlpha)),
              width: AppTokens.dividerWidth,
            ),
          ),
          boxShadow: _isPressed
              ? null
              : [
                  BoxShadow(
                    color: widget.shadowColor ?? (widget.backgroundColor ?? AppColors.white).withAlpha(AppTokens.dividerAlpha),
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  )
                ],
        ),
        child: Icon(widget.icon, color: widget.iconColor ?? AppColors.primary, size: AppTokens.headerIconSize),
      ),
    );
  }
}
