import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:vocabu_rex_mobile/profile/domain/entities/profile_entity.dart';
import 'package:vocabu_rex_mobile/friend/ui/widgets/find_friends_view.dart';
import 'package:vocabu_rex_mobile/friend/ui/widgets/friends_list_view.dart';

/// Section chứa các nút hành động và thống kê theo dõi
class ProfileActionButtons extends StatelessWidget {
  final ProfileEntity? profile;

  const ProfileActionButtons({
    Key? key,
    required this.profile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        children: [
          // Thống kê theo dõi (labels always blue)
          Row(
            children: [
              // Đang theo dõi (clickable)
              Flexible(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const FriendsListView(initialTabIndex: 0),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                            .chain(CurveTween(curve: Curves.easeOut));
                        return SlideTransition(position: animation.drive(tween), child: child);
                      },
                      transitionDuration: const Duration(milliseconds: 320),
                    ));
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'Đang theo dõi ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.macaw,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${profile?.followingCount ?? 0}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.macaw,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              // Người theo dõi (clickable)
              Flexible(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const FriendsListView(initialTabIndex: 1),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                            .chain(CurveTween(curve: Curves.easeOut));
                        return SlideTransition(position: animation.drive(tween), child: child);
                      },
                      transitionDuration: const Duration(milliseconds: 320),
                    ));
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${profile?.followerCount ?? 0}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.macaw,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          'Người theo dõi',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.macaw,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Nút bấm
          Row(
            children: [
              Expanded(
                child: AppButton(
                  onPressed: () {},
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const FindFriendsView(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                              .chain(CurveTween(curve: Curves.easeOut));
                          return SlideTransition(position: animation.drive(tween), child: child);
                        },
                        transitionDuration: const Duration(milliseconds: 320),
                      ));
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_add, size: 18.sp, color: AppColors.snow),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: Text(
                            'THÊM BẠN BÈ',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: AppColors.snow,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  variant: ButtonVariant.primary,
                  size: ButtonSize.medium,
                  shadowOpacity: 0.6,
                ),
              ),
              SizedBox(width: 12.w),
              AppButton(
                onPressed: () {},
                child: Icon(Icons.ios_share_outlined, size: 20.sp, color: AppColors.snow),
                variant: ButtonVariant.primary,
                size: ButtonSize.small,
                width: 56.w,
                shadowOpacity: 0.6,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
