import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:animate_do/animate_do.dart';

class Option extends StatefulWidget {
  final String label;
  final bool isSelected;
  final int index;
  final Function(int) onSelect;

  const Option({
    super.key,
    required this.isSelected,
    required this.label,
    required this.index,
    required this.onSelect,
  });

  @override
  State<Option> createState() => _OptionState();
}

class _OptionState extends State<Option> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      delay: Duration(milliseconds: 100 * widget.index),
      duration: const Duration(milliseconds: 400),
      from: 30,
      child: GestureDetector(
        onTapDown: (_) => _scaleController.forward(),
        onTapUp: (_) {
          _scaleController.reverse();
          widget.onSelect(widget.index);
        },
        onTapCancel: () => _scaleController.reverse(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            height: 50.h,
            margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: widget.isSelected ? AppColors.macaw.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.all(Radius.circular(18.r)),
              border: widget.isSelected
                  ? Border.all(color: AppColors.macaw, width: 3)
                  : Border.all(color: AppColors.swan, width: 2),
            ),
            child: Center(
              child: Text(
                widget.label,
                style: TextStyle(
                  color: widget.isSelected ? AppColors.macaw : AppColors.wolf, 
                  fontSize: 16.sp,
                  fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
