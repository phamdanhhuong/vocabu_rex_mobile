import 'package:flutter/material.dart';

/// Action card button with QuestActionButton-like animation
/// Used for action cards in friend finding, settings, etc.
class ActionCardButton extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String text;
  final VoidCallback onTap;
  final double borderRadius;
  final Color borderColor;
  final Color backgroundColor;

  const ActionCardButton({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.text,
    required this.onTap,
    this.borderRadius = 16.0,
    this.borderColor = const Color(0xFFE5E5E5),
    this.backgroundColor = const Color(0xFFFFFFFF),
  }) : super(key: key);

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
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: widget.borderColor, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: _pressed ? Colors.transparent : const Color(0xFFE5E5E5),
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
                style: const TextStyle(
                  color: Color(0xFF4B4B4B),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
