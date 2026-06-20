import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/achievement/ui/blocs/achievement_bloc.dart';
import 'package:vocabu_rex_mobile/achievement/ui/widgets/achievement_detail_dialog.dart';
import 'package:vocabu_rex_mobile/achievement/ui/widgets/achievement_record_card.dart';
import 'package:vocabu_rex_mobile/achievement/ui/widgets/achievement_tile.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/web/widgets/web_page_wrapper.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import 'package:vocabu_rex_mobile/theme/widgets/horizontal_carousel.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';

// --- Định nghĩa màu sắc (nếu cần) ---
Color get _grayText => AppColors.wolf;
Color get _pageBackground => AppColors.snow;

/// Giao diện màn hình "Xem tất cả thành tích".
class AllAchievementsView extends StatefulWidget {
  const AllAchievementsView({super.key});

  @override
  State<AllAchievementsView> createState() => _AllAchievementsViewState();
}

class _AllAchievementsViewState extends State<AllAchievementsView> {
  @override
  void initState() {
    super.initState();
    // Load achievements when widget is initialized
    context.read<AchievementBloc>().add(LoadAchievementsSummaryEvent());
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
              leading: FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: _grayText, size: 28),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
          title: FadeInDown(
            duration: const Duration(milliseconds: 500),
            child: Text(
              'Thành tích',
              style: TextStyle(
                color: AppColors.bodyText,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<AchievementBloc, AchievementState>(
          builder: (context, state) {
            if (state is AchievementLoading) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Kỷ lục cá nhân'),
                    _buildSkeletonCarousel(height: 180),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Giải thưởng'),
                    _buildSkeletonGrid(),
                  ],
                ),
              );
            }

            if (state is AchievementError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.cardinal,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Có lỗi xảy ra',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.bodyText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: TextStyle(fontSize: 14, color: _grayText),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AchievementBloc>().add(
                          LoadAchievementsSummaryEvent(),
                        );
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            if (state is AchievementLoaded) {
              final personalAchievements = state.personalAchievements ?? [];
              final awardsAchievements = state.awardsAchievements ?? [];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Kỷ lục cá nhân (personal category only)
                    _buildSectionHeader('Kỷ lục cá nhân'),
                    _buildRecordsList(personalAchievements),

                    const SizedBox(height: 32),

                    // 2. Giải thưởng (highest tier from each other category)
                    _buildSectionHeader('Giải thưởng'),
                    _buildAwardsGrid(awardsAchievements),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  },
);
}

  /// Tiêu đề cho mỗi mục (ví dụ: "Kỷ lục cá nhân")
  Widget _buildSectionHeader(String title) {
    return FadeInLeft(
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
        child: Text(
          title,
          style: TextStyle(
            color: AppColors.bodyText,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Danh sách cuộn ngang cho "Kỷ lục cá nhân"
  Widget _buildRecordsList(List achievements) {
    if (achievements.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Chưa có kỷ lục nào',
            style: TextStyle(fontSize: 14, color: _grayText),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth - 32; // 32 is carousel padding
        // Giả sử mỗi thẻ kỷ lục rộng khoảng 200
        final int itemsPerPage = (availableWidth / 200).floor().clamp(1, 10);

        final List<Widget> pages = [];
        for (int i = 0; i < achievements.length; i += itemsPerPage) {
          final chunk = achievements.sublist(
            i,
            (i + itemsPerPage > achievements.length) ? achievements.length : i + itemsPerPage,
          );
          pages.add(
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: chunk.asMap().entries.map((entry) {
                final index = entry.key;
                final ach = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: FadeInRight(
                    duration: const Duration(milliseconds: 500),
                    delay: Duration(milliseconds: index * 100),
                    child: AchievementRecordCard(achievement: ach),
                  ),
                );
              }).toList(),
            ),
          );
        }
        return SizedBox(
          height: 200, // Chiều cao cố định cho danh sách ngang
          child: HorizontalCarousel(pages: pages),
        );
      },
    );
  }

  /// Lưới ngang cho "Giải thưởng" (4 hàng mỗi trang)
  Widget _buildAwardsGrid(List achievements) {
    if (achievements.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'Chưa có thành tích nào',
            style: TextStyle(fontSize: 16, color: _grayText),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth - 32;
        final int itemsPerRow = (availableWidth / 120).floor().clamp(1, 10);
        final int itemsPerPage = itemsPerRow * 3; // 3 rows per page

        final List<Widget> pages = [];
        for (int i = 0; i < achievements.length; i += itemsPerPage) {
          final chunk = achievements.sublist(
            i,
            (i + itemsPerPage > achievements.length) ? achievements.length : i + itemsPerPage,
          );
          
          pages.add(
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: itemsPerRow,
                childAspectRatio: 0.65, // Tỷ lệ (rộng/cao) của mỗi ô, giảm xuống để thẻ cao hơn và hình to hơn
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              itemCount: chunk.length,
              itemBuilder: (context, index) {
                final ach = chunk[index];
                return BounceInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: Duration(milliseconds: index * 50),
                  child: AchievementTile(
                    achievement: ach,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AchievementDetailDialog(achievement: ach),
                      );
                    },
                  ),
                );
              },
            ),
          );
        }

        return HorizontalCarousel(pages: pages);
      },
    );
  }

  Widget _buildSkeletonCarousel({required double height}) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Shimmer.fromColors(
              baseColor: AppColors.swan.withValues(alpha: 0.5),
              highlightColor: AppColors.snow,
              child: Container(
                width: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth - 32;
        final int itemsPerRow = (availableWidth / 120).floor().clamp(1, 10);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: itemsPerRow,
            childAspectRatio: 0.65,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: itemsPerRow * 3, // Skeleton cho 3 hàng
          itemBuilder: (context, index) {
            return Shimmer.fromColors(
              baseColor: AppColors.swan.withValues(alpha: 0.5),
              highlightColor: AppColors.snow,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
