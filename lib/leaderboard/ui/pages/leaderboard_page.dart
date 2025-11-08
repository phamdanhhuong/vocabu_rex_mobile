import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

/// Trang Bảng xếp hạng (Leaderboard)
class LeaderBoardPage extends StatefulWidget {
  const LeaderBoardPage({Key? key}) : super(key: key);

  @override
  State<LeaderBoardPage> createState() => _LeaderBoardPageState();
}

class _LeaderBoardPageState extends State<LeaderBoardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.snow,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bảng xếp hạng',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.bodyText,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.info_outline, color: AppColors.macaw, size: 24.sp),
                    onPressed: () {
                      // Show info dialog
                    },
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppColors.polar,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.macaw,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                labelColor: AppColors.snow,
                unselectedLabelColor: AppColors.wolf,
                labelStyle: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: theme.textTheme.labelLarge,
                tabs: [
                  Tab(text: 'Tuần này'),
                  Tab(text: 'Tháng này'),
                  Tab(text: 'Toàn thời gian'),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // TabBarView
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLeaderboardList('week'),
                  _buildLeaderboardList('month'),
                  _buildLeaderboardList('all'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardList(String period) {
    // Mock data
    final leaderboardData = List.generate(
      20,
      (index) => {
        'rank': index + 1,
        'name': 'Người dùng ${index + 1}',
        'avatar': '',
        'exp': (1000 - index * 50),
        'streak': (30 - index),
      },
    );

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: leaderboardData.length,
      itemBuilder: (context, index) {
        final user = leaderboardData[index];
        final rank = user['rank'] as int;
        final isTopThree = rank <= 3;

        return Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: isTopThree ? AppColors.bee.withOpacity(0.1) : AppColors.snow,
            border: Border.all(
              color: isTopThree ? AppColors.bee : AppColors.swan,
              width: 2.w,
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              // Rank badge
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: _getRankColor(rank),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    rank <= 3 ? _getRankIcon(rank) : '$rank',
                    style: TextStyle(
                      color: AppColors.snow,
                      fontSize: rank <= 3 ? 20.sp : 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              // Avatar
              CircleAvatar(
                radius: 24.r,
                backgroundColor: AppColors.cardinal.withOpacity(0.2),
                child: Icon(Icons.person, color: AppColors.cardinal, size: 24.sp),
              ),
              SizedBox(width: 12.w),

              // Name and stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['name'] as String,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.bodyText,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(Icons.flash_on, color: AppColors.bee, size: 16.sp),
                        SizedBox(width: 4.w),
                        Text(
                          '${user['exp']} KN',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.wolf,
                              ),
                        ),
                        SizedBox(width: 12.w),
                        Icon(Icons.whatshot, color: AppColors.fox, size: 16.sp),
                        SizedBox(width: 4.w),
                        Text(
                          '${user['streak']} ngày',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.wolf,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.bee; // Gold
      case 2:
        return AppColors.wolf; // Silver
      case 3:
        return AppColors.fox; // Bronze
      default:
        return AppColors.macaw; // Blue
    }
  }

  String _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '';
    }
  }
}
