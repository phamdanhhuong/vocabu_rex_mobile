import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/achievement/data/datasources/achievement_datasource_impl.dart';
import 'package:vocabu_rex_mobile/achievement/data/repositories/achievement_repository_impl.dart';
import 'package:vocabu_rex_mobile/achievement/data/service/achievement_service.dart';
import 'package:vocabu_rex_mobile/achievement/domain/usecases/get_achievements_by_category_usecase.dart';
import 'package:vocabu_rex_mobile/achievement/domain/usecases/get_achievements_usecase.dart';
import 'package:vocabu_rex_mobile/achievement/domain/usecases/get_recent_achievements_usecase.dart';
import 'package:vocabu_rex_mobile/achievement/domain/usecases/get_achievements_summary_usecase.dart';
import 'package:vocabu_rex_mobile/achievement/ui/blocs/achievement_bloc.dart';
import 'package:vocabu_rex_mobile/achievement/ui/widgets/achievement_detail_dialog.dart';
import 'package:vocabu_rex_mobile/achievement/ui/widgets/achievement_record_card.dart';
import 'package:vocabu_rex_mobile/achievement/ui/widgets/achievement_tile.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

// --- Định nghĩa màu sắc (nếu cần) ---
const Color _grayText = Color(0xFF777777); // Giống wolf
const Color _pageBackground = Color(0xFFFFFFFF);

/// Giao diện màn hình "Xem tất cả thành tích".
class AllAchievementsView extends StatelessWidget {
  const AllAchievementsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize dependencies
    final achievementService = AchievementService();
    final achievementDataSource = AchievementDataSourceImpl(achievementService);
    final achievementRepository = AchievementRepositoryImpl(achievementDataSource);
    
    final getAchievementsUsecase = GetAchievementsUsecase(achievementRepository);
    final getAchievementsByCategoryUsecase = GetAchievementsByCategoryUsecase(achievementRepository);
    final getRecentAchievementsUsecase = GetRecentAchievementsUsecase(achievementRepository);
    final getAchievementsSummaryUsecase = GetAchievementsSummaryUsecase(achievementRepository);

    return BlocProvider(
      create: (context) => AchievementBloc(
        getAchievementsUsecase: getAchievementsUsecase,
        getAchievementsByCategoryUsecase: getAchievementsByCategoryUsecase,
        getRecentAchievementsUsecase: getRecentAchievementsUsecase,
        getAchievementsSummaryUsecase: getAchievementsSummaryUsecase,
      )..add(LoadAchievementsSummaryEvent()),
      child: Scaffold(
        backgroundColor: _pageBackground,
        appBar: AppBar(
          backgroundColor: _pageBackground,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: _grayText, size: 28),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text(
            'Thành tích',
            style: TextStyle(
              color: AppColors.bodyText,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<AchievementBloc, AchievementState>(
          builder: (context, state) {
            if (state is AchievementLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.featherGreen),
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
                    const Text(
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
                      style: const TextStyle(
                        fontSize: 14,
                        color: _grayText,
                      ),
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
  }

  // --- WIDGET CON (HELPER) ---

  /// Tiêu đề cho mỗi mục (ví dụ: "Kỷ lục cá nhân")
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.bodyText,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Danh sách cuộn ngang cho "Kỷ lục cá nhân"
  Widget _buildRecordsList(List achievements) {
    if (achievements.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'Chưa có kỷ lục nào',
            style: TextStyle(fontSize: 14, color: _grayText),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200, // Chiều cao cố định cho danh sách ngang
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          return AchievementRecordCard(
            achievement: achievements[index],
          );
        },
      ),
    );
  }

  /// Lưới 3 cột cho "Giải thưởng"
  Widget _buildAwardsGrid(List achievements) {
    if (achievements.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'Chưa có thành tích nào',
            style: TextStyle(fontSize: 16, color: _grayText),
          ),
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 cột
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.75, // Tỷ lệ (rộng/cao) của mỗi ô
      ),
      itemCount: achievements.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Tắt cuộn của GridView
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return AchievementTile(
          achievement: achievement,
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AchievementDetailDialog(
                achievement: achievement,
              ),
            );
          },
        );
      },
    );
  }
}
