import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/web/widgets/web_page_wrapper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/action_card_button.dart';
import 'package:vocabu_rex_mobile/theme/widgets/horizontal_carousel.dart';
import 'package:vocabu_rex_mobile/friend/ui/widgets/search_friends_by_name_view.dart';
import 'package:vocabu_rex_mobile/friend/ui/blocs/friend_bloc.dart';
import 'package:vocabu_rex_mobile/friend/domain/entities/user_entity.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/dot_loading_indicator.dart';

import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import 'package:share_plus/share_plus.dart';

// --- Định nghĩa màu sắc mới dựa trên ảnh (Find Friends Screen) ---
Color get _cardBorderColor => AppColors.swan;
Color get _grayText => AppColors.wolf;
Color get _blueText => AppColors.macaw;
Color get _pageBackground => AppColors.snow;

/// Giao diện màn hình "Tìm bạn bè".
class FindFriendsView extends StatefulWidget {
  const FindFriendsView({super.key});

  @override
  State<FindFriendsView> createState() => _FindFriendsViewState();
}

class _FindFriendsViewState extends State<FindFriendsView> {
  @override
  void initState() {
    super.initState();
    // Load suggested friends when screen loads
    context.read<FriendBloc>().add(GetSuggestedFriendsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppPreferences(),
      builder: (context, _) {
        return WebPageWrapper(
          mobileScaffold: Scaffold(
            backgroundColor: _pageBackground,
            appBar: AppBar(
              backgroundColor: _pageBackground,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: _grayText, size: 28),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Tiêu đề "Tìm bạn bè"
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Tìm bạn bè',
                  style: TextStyle(
                    color: AppColors.bodyText,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 2. Các nút hành động
              _buildActionCard(
                icon: Icons.contacts,
                iconColor: AppPreferences().isDarkMode ? Colors.orange[300]! : Colors.orange[700]!,
                iconBackgroundColor: AppPreferences().isDarkMode ? Colors.orange[900]!.withOpacity(0.5) : Colors.orange[100]!,
                text: 'Chọn từ danh bạ',
                onTap: () {},
              ),
              _buildActionCard(
                icon: Icons.search,
                iconColor: AppPreferences().isDarkMode ? Colors.blue[300]! : Colors.blue[700]!,
                iconBackgroundColor: AppPreferences().isDarkMode ? Colors.blue[900]!.withOpacity(0.5) : Colors.blue[100]!,
                text: 'Tìm theo tên',
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const SearchFriendsView(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            final tween = Tween(
                              begin: const Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).chain(CurveTween(curve: Curves.easeOut));
                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                      transitionDuration: const Duration(milliseconds: 320),
                    ),
                  );
                },
              ),
              _buildActionCard(
                icon: Icons.share,
                iconColor: AppPreferences().isDarkMode ? Colors.purple[300]! : Colors.purple[700]!,
                iconBackgroundColor: AppPreferences().isDarkMode ? Colors.purple[900]!.withOpacity(0.5) : Colors.purple[100]!,
                text: 'Chia sẻ đường dẫn kết bạn',
                onTap: () {
                  Share.share(
                    'Tôi đang luyện tiếng Anh rất vui trên VocabuRex. Tải và học cùng tôi ngay!\n'
                    'Link: http://213.35.101.223:8080/',
                  );
                },
              ),
              const SizedBox(height: 32),

              // 3. Mục "Gợi ý kết bạn"
              _SectionHeader(title: 'Gợi ý kết bạn', actionText: 'XEM TẤT CẢ'),
              BlocBuilder<FriendBloc, FriendState>(
                builder: (context, state) {
                  if (state is FriendLoading) {
                    return SizedBox(
                      height: 240.h,
                      child: Center(
                        child: DotLoadingIndicator(
                          color: AppColors.macaw,
                          size: 16.0,
                        ),
                      ),
                    );
                  } else if (state is SuggestedFriendsLoaded) {
                    return _buildSuggestionsList(context, state.suggestions);
                  } else if (state is FriendError) {
                    return SizedBox(
                      height: 240.h,
                      child: Center(
                        child: Text(
                          'Lỗi: ${state.message}',
                          style: TextStyle(color: _grayText),
                        ),
                      ),
                    );
                  }
                  return _buildSuggestionsList(context, []);
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  },
);
}

  // --- WIDGET CON (HELPER) ---

  /// Thẻ hành động (ví dụ: "Chọn từ danh bạ")
  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBackgroundColor,
    required String text,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: ActionCardButton(
        icon: icon,
        iconColor: iconColor,
        iconBackgroundColor: iconBackgroundColor,
        text: text,
        onTap: onTap,
      ),
    );
  }

  /// Danh sách cuộn ngang cho các gợi ý
  Widget _buildSuggestionsList(
    BuildContext context,
    List<UserEntity> suggestions,
  ) {
    if (suggestions.isEmpty) {
      return SizedBox(
        height: 240.h,
        child: Center(
          child: Text(
            'Không có gợi ý nào',
            style: TextStyle(color: _grayText, fontSize: 16.sp),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Mỗi thẻ rộng 160.w + margin 12.w = 172.w. Trừ đi 32.w padding của carousel
        final double availableWidth = constraints.maxWidth - 32.w;
        final int itemsPerPage = (availableWidth / 172.w).floor().clamp(1, 10);
        
        final List<Widget> pages = [];
        
        for (int i = 0; i < suggestions.length; i += itemsPerPage) {
          final chunk = suggestions.sublist(
            i,
            i + itemsPerPage > suggestions.length ? suggestions.length : i + itemsPerPage,
          );
          pages.add(
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: chunk.map((suggestion) {
                return _SuggestionCard(
                  user: suggestion,
                  onFollow: () {
                    context.read<FriendBloc>().add(FollowUserEvent(suggestion.id));
                  },
                  onDismiss: () {
                    // TODO: Implement dismiss suggestion
                  },
                );
              }).toList(),
            ),
          );
        }

        return HorizontalCarousel(pages: pages);
      },
    );
  }
}

/// Thẻ gợi ý kết bạn
class _SuggestionCard extends StatelessWidget {
  final UserEntity user;
  final VoidCallback onFollow;
  final VoidCallback onDismiss;

  const _SuggestionCard({
    required this.user,
    required this.onFollow,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160.w,
      margin: EdgeInsets.only(right: 12.w),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: _cardBorderColor, width: 2.w),
        ),
        color: _pageBackground,
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Nút X (để đóng)
              Align(
                alignment: Alignment.topRight,
                child: SizedBox(
                  width: 24.w,
                  height: 24.h,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    iconSize: 16.sp,
                    icon: Icon(Icons.close, color: _grayText),
                    onPressed: onDismiss,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              // Avatar
              CircleAvatar(
                radius: 26.r,
                backgroundColor: AppColors.polar,
                backgroundImage: user.avatarUrl.isNotEmpty
                    ? NetworkImage(user.avatarUrl)
                    : null,
                child: user.avatarUrl.isEmpty
                    ? Icon(Icons.person, size: 32.sp, color: AppColors.wolf)
                    : null,
              ),
              SizedBox(height: 8.h),
              // Thông tin
              Flexible(
                child: Text(
                  user.displayName,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.bodyText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 4.h),
              Flexible(
                child: Text(
                  user.subtext ?? '',
                  style: TextStyle(fontSize: 12.sp, color: _grayText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 10.h),
              // Nút "THEO DÕI"
              AppButton(
                label: 'THEO DÕI',
                onPressed: onFollow,
                variant: ButtonVariant.alternate,
                width: double.infinity,
                size: ButtonSize.small,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tiêu đề cho mỗi mục (ví dụ: "Gợi ý kết bạn")
/// (Tái sử dụng logic từ ProfileView)
class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;

  const _SectionHeader({required this.title, required this.actionText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.bodyText,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            actionText,
            style: TextStyle(
              color: _blueText,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
