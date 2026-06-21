import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/profile/ui/pages/settings_page.dart';

/// AppBar của Profile page
class ProfileAppBar extends StatelessWidget {
  final bool isDark;
  const ProfileAppBar({super.key, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = kIsWeb && MediaQuery.of(context).size.width >= 768;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 8.h,
      ).copyWith(top: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 40.w), // Placeholder cho cân bằng
          Text(
            'Hồ sơ',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: isDark ? AppColors.snow : AppColors.bodyText,
            ),
          ),
          if (!isWide)
            IconButton(
              icon: Icon(Icons.settings, color: isDark ? AppColors.snow : AppColors.macaw, size: 28.sp),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const SettingsPage(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          var fadeAnimation = Tween(begin: 0.0, end: 1.0)
                              .animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOut,
                              ));
                          return FadeTransition(
                            opacity: fadeAnimation,
                            child: child,
                          );
                        },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );
              },
            )
          else
            SizedBox(width: 48.w),
        ],
      ),
    );
  }
}
