import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';

class StaticDocumentPage extends StatelessWidget {
  final String title;
  final String content;

  const StaticDocumentPage({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = AppPreferences().isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.snow,
      appBar: AppBar(
        backgroundColor: AppColors.snow,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.bodyText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.bodyText,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(
            color: AppColors.swan,
            height: 2.0,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.polar : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.swan, width: 2),
            ),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 15.sp,
                height: 1.6,
                color: AppColors.bodyText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
