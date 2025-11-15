import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

/// AppBar của Profile page
class ProfileAppBar extends StatelessWidget {
  const ProfileAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h)
          .copyWith(top: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 40.w), // Placeholder cho cân bằng
          Text(
            'Hồ sơ',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: AppColors.bodyText,
            ),
          ),
          IconButton(
            icon: Icon(Icons.settings, color: AppColors.macaw, size: 28.sp),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
