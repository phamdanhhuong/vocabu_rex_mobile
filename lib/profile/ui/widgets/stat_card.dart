import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

/// Thẻ thống kê hiển thị icon, giá trị và nhãn
class StatCard extends StatelessWidget {
  final Widget icon;
  final String value;
  final String label;

  const StatCard({
    Key? key,
    required this.icon,
    required this.value,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.all(0.w),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.swan, width: 2.w),
      ),
      child: Row(
        children: [
          // Left: icon area with fixed width for consistent alignment
          SizedBox(
            width: 44.w,
            child: Center(child: icon),
          ),
          SizedBox(width: 8.w),
          // Right: value + label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.bodyText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Flexible(
                  child: Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.wolf,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
