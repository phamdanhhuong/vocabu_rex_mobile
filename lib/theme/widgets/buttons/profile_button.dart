import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../colors.dart';

/// Custom button widget with QuestActionButton-like animation and style
/// Used in profile action buttons (Add Friend, Share, etc.)
class ProfileButton extends StatefulWidget {
  final IconData icon;
  final String? label;
  final VoidCallback? onPressed;
  final bool isIconOnly;

  const ProfileButton({
    Key? key,
    required this.icon,
    this.label,
    this.onPressed,
    this.isIconOnly = false,
  }) : super(key: key);

  @override
  State<ProfileButton> createState() => _ProfileButtonState();
}

class _ProfileButtonState extends State<ProfileButton> {
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
      onTap: widget.onPressed,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: _pressDuration,
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _pressed ? 3.0 : 0.0, 0),
        padding: EdgeInsets.symmetric(
          vertical: 12.h,
          horizontal: widget.isIconOnly ? 0 : 16.w,
        ),
        width: widget.isIconOnly ? 56.w : null,
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
        child: widget.isIconOnly
            ? Icon(
                widget.icon,
                size: 20.sp,
                color: AppColors.bodyText,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    size: 18.sp,
                    color: AppColors.bodyText,
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      widget.label ?? '',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.bodyText,
                        letterSpacing: 0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
