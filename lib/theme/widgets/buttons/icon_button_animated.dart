import 'package:flutter/material.dart';

/// Animated icon button with press effect similar to QuestActionButton
/// Used throughout the app for consistent button animations
class IconButtonAnimated extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color? borderColor;
  final Color? shadowColor;
  final double iconSize;
  final double padding;
  final double borderRadius;
  final double? borderWidth;
  final VoidCallback? onPressed;
  final bool isDisabled;

  const IconButtonAnimated({
    Key? key,
    required this.icon,
    this.iconColor = Colors.white,
    this.backgroundColor = const Color(0xFF1CB0F6),
    this.borderColor,
    this.shadowColor,
    this.iconSize = 24,
    this.padding = 8.0,
    this.borderRadius = 8.0,
    this.borderWidth,
    this.onPressed,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  State<IconButtonAnimated> createState() => _IconButtonAnimatedState();
}

class _IconButtonAnimatedState extends State<IconButtonAnimated> {
  bool _pressed = false;
  static const Duration _pressDuration = Duration(milliseconds: 90);

  void _setPressed(bool value) {
    if (widget.isDisabled) return;
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveShadowColor = widget.shadowColor ?? 
        widget.backgroundColor.withOpacity(0.3);

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.isDisabled ? null : widget.onPressed,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: _pressDuration,
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _pressed ? 3.0 : 0.0, 0),
        padding: EdgeInsets.all(widget.padding),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: widget.borderColor != null && widget.borderWidth != null
              ? Border.all(
                  color: widget.borderColor!,
                  width: widget.borderWidth!,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: _pressed ? Colors.transparent : effectiveShadowColor,
              offset: _pressed ? const Offset(0, 0) : const Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Icon(
          widget.icon,
          color: widget.iconColor,
          size: widget.iconSize,
        ),
      ),
    );
  }
}
