import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/profile_button.dart';
import 'package:vocabu_rex_mobile/profile/domain/entities/profile_entity.dart';
import 'package:vocabu_rex_mobile/friend/ui/widgets/find_friends_view.dart';
import 'package:vocabu_rex_mobile/friend/ui/widgets/friends_list_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:animate_do/animate_do.dart';

/// Section chứa các nút hành động và thống kê theo dõi
class ProfileActionButtons extends StatelessWidget {
  final ProfileEntity? profile;

  const ProfileActionButtons({super.key, required this.profile});

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
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            FadeInUp(
                              duration: const Duration(milliseconds: 400),
                              child: const FriendsListView(initialTabIndex: 0),
                            ),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 400),
                      ),
                    );
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
                            fontWeight: FontWeight.bold,
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
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            FadeInUp(
                              duration: const Duration(milliseconds: 400),
                              child: const FriendsListView(initialTabIndex: 1),
                            ),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 400),
                      ),
                    );
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
                            fontWeight: FontWeight.bold,
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
                child: ProfileButton(
                  icon: Icons.person_add,
                  label: 'THÊM BẠN BÈ',
                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            FadeInUp(
                              duration: const Duration(milliseconds: 400),
                              child: const FindFriendsView(),
                            ),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 400),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 12.w),
              ProfileButton(
                icon: Icons.ios_share_outlined,
                onPressed: () {
                  Share.share(
                    'Cùng học tiếng Anh với tôi trên VocabuRex nhé!\n'
                    'Truy cập ngay tại: http://213.35.101.223:8080/',
                  );
                },
                isIconOnly: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
