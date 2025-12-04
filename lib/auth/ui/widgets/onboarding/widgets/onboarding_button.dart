import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import '../models/onboarding_models.dart';

/// Onboarding button with press animation and state changes
/// Based on AppButton and ProfileButton design
class OnboardingButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final OnboardingButtonState state;
  final double? width;
  
  const OnboardingButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.state = OnboardingButtonState.enabled,
    this.width,
  }) : super(key: key);

  @override
  State<OnboardingButton> createState() => _OnboardingButtonState();
}

class _OnboardingButtonState extends State<OnboardingButton> {
  bool _pressed = false;
  static const Duration _pressDuration = Duration(milliseconds: 90);

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  Color get _backgroundColor {
    switch (widget.state) {
      case OnboardingButtonState.selected:
        return AppColors.featherGreen;
      case OnboardingButtonState.disabled:
        return AppColors.swan;
      case OnboardingButtonState.enabled:
        return AppColors.featherGreen; // Xanh Duolingo
    }
  }

  Color get _textColor {
    switch (widget.state) {
      case OnboardingButtonState.selected:
        return AppColors.snow;
      case OnboardingButtonState.disabled:
        return AppColors.hare;
      case OnboardingButtonState.enabled:
        return AppColors.snow; // Text trắng trên nền xanh
    }
  }

  Color get _shadowColor {
    switch (widget.state) {
      case OnboardingButtonState.selected:
        return AppColors.wingOverlay; // Dark green shadow
      case OnboardingButtonState.disabled:
        return AppColors.hare;
      case OnboardingButtonState.enabled:
        return AppColors.wingOverlay; // Dark green shadow
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPress = widget.state != OnboardingButtonState.disabled 
                     && widget.onPressed != null;
    
    return GestureDetector(
      onTapDown: canPress ? (_) => _setPressed(true) : null,
      onTapUp: canPress ? (_) => _setPressed(false) : null,
      onTapCancel: canPress ? () => _setPressed(false) : null,
      onTap: canPress ? widget.onPressed : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: _pressDuration,
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _pressed ? 4.0 : 0.0, 0),
        width: widget.width ?? double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(16.w),
          boxShadow: [
            BoxShadow(
              color: _pressed ? Colors.transparent : _shadowColor,
              offset: _pressed ? Offset.zero : const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          widget.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: _textColor,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
