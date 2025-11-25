import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../colors.dart';

/// Reusable quest action button with emoji icon and label
/// Used in quest cards (friends quest, etc.)
class QuestActionButton extends StatefulWidget {
  final String emoji;
  final String label;
  final VoidCallback? onPressed;
  final bool isDisabled;

  const QuestActionButton({
    Key? key,
    required this.emoji,
    required this.label,
    this.onPressed,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  State<QuestActionButton> createState() => _QuestActionButtonState();
}

class _QuestActionButtonState extends State<QuestActionButton> {
  bool _pressed = false;
  static const Duration _pressDuration = Duration(milliseconds: 90);

  void _setPressed(bool value) {
    if (widget.isDisabled) return;
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = widget.isDisabled ? null : widget.onPressed;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: effectiveOnPressed,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: _pressDuration,
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _pressed ? 3.0 : 0.0, 0),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.snow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.feedDivider,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _pressed ? Colors.transparent : AppColors.swan,
              offset: _pressed ? const Offset(0, 0) : const Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.emoji,
              style: TextStyle(fontSize: 20.sp),
            ),
            SizedBox(width: 8.w),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.bodyText,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
