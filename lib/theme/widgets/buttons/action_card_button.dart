import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';

/// Action card button with QuestActionButton-like animation
/// Used for action cards in friend finding, settings, etc.
class ActionCardButton extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String text;
  final VoidCallback onTap;
  final double borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;

  const ActionCardButton({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.text,
    required this.onTap,
    this.borderRadius = 16.0,
    this.borderColor,
    this.backgroundColor,
  });

  @override
  State<ActionCardButton> createState() => _ActionCardButtonState();
}

class _ActionCardButtonState extends State<ActionCardButton> {
  bool _pressed = false;
  static const Duration _pressDuration = Duration(milliseconds: 90);

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppPreferences(),
      builder: (context, _) {
        final effectiveBgColor = widget.backgroundColor ?? AppColors.snow;
        final effectiveBorderColor = widget.borderColor ?? AppColors.swan;
        final effectiveShadowColor = AppColors.hare;
        final effectiveTextColor = AppColors.bodyText;

        return GestureDetector(
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: _pressDuration,
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(0, _pressed ? 3.0 : 0.0, 0),
            decoration: BoxDecoration(
              color: effectiveBgColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(color: effectiveBorderColor, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: _pressed ? Colors.transparent : effectiveShadowColor,
                  offset: _pressed ? const Offset(0, 0) : const Offset(0, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Icon với nền màu
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: widget.iconBackgroundColor,
                    child: Icon(widget.icon, color: widget.iconColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    widget.text,
                    style: TextStyle(
                      color: effectiveTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
