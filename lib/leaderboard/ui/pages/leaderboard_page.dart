import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/leaderboard/ui/blocs/leaderboard_bloc.dart';
import 'package:vocabu_rex_mobile/leaderboard/ui/blocs/leaderboard_event.dart';
import 'package:vocabu_rex_mobile/leaderboard/ui/blocs/leaderboard_state.dart';
import 'package:vocabu_rex_mobile/leaderboard/ui/widgets/league_header_widget.dart';
import 'package:vocabu_rex_mobile/leaderboard/ui/widgets/leaderboard_tile.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/dot_loading_indicator.dart';

/// Trang Bảng xếp hạng (Leaderboard) - Duolingo style
class LeaderBoardPage extends StatefulWidget {
  const LeaderBoardPage({Key? key}) : super(key: key);

  @override
  State<LeaderBoardPage> createState() => _LeaderBoardPageState();
}

class _LeaderBoardPageState extends State<LeaderBoardPage> {
  @override
  void initState() {
    super.initState();
    // Load leaderboard data when page loads
    context.read<LeaderboardBloc>().add(LoadLeaderboardEvent());
  }

  @override
  Widget build(BuildContext context) {
    return const _LeaderBoardPageContent();
  }
}

class _LeaderBoardPageContent extends StatelessWidget {
  const _LeaderBoardPageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.end,
            //     children: [
            //       IconButton(
            //         icon: Icon(Icons.info_outline, color: AppColors.macaw, size: 24.sp),
            //         onPressed: () => _showInfoDialog(context),
            //       ),
            //     ],
            //   ),
            // ),

            // Content
            Expanded(
              child: BlocBuilder<LeaderboardBloc, LeaderboardState>(
                builder: (context, state) {
                  if (state is LeaderboardLoading) {
                    return const Center(
                      child: DotLoadingIndicator(color: AppColors.featherGreen, size: 16),
                    );
                  }

                  if (state is LeaderboardNotEligible) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 100.sp,
                              color: AppColors.macaw,
                            ),
                            SizedBox(height: 24.h),
                            Text(
                              'Chưa đủ điều kiện',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: AppColors.eel,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Hoàn thành ít nhất 1 bài tập để tham gia bảng xếp hạng!',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: AppColors.wolf,
                              ),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is LeaderboardError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64.sp, color: AppColors.cardinal),
                          SizedBox(height: 16.h),
                          Text(
                            'Không thể tải bảng xếp hạng',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColors.eel,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            state.message,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.wolf,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24.h),
                          ElevatedButton(
                            onPressed: () {
                              context.read<LeaderboardBloc>().add(LoadLeaderboardEvent());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.featherGreen,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is LeaderboardLoaded) {
                    final leaderboard = state.leaderboard;

                    // Calculate days remaining
                    final daysRemaining = leaderboard.weekEndDate.difference(DateTime.now()).inDays;

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<LeaderboardBloc>().add(RefreshLeaderboardEvent());
                        await Future.delayed(const Duration(seconds: 1));
                      },
                      color: AppColors.featherGreen,
                      child: ListView(
                        children: [
                          // League header
                          LeagueHeaderWidget(
                            tier: leaderboard.tier,
                            daysRemaining: daysRemaining > 0 ? daysRemaining : 0,
                          ),
                          SizedBox(height: 16.h),

                          // Promotion zone label
                          _buildZoneLabel(
                            'NHÓM THĂNG HẠNG',
                            AppColors.featherGreen,
                            Icons.arrow_upward,
                          ),
                          SizedBox(height: 8.h),

                          // Top 10 (Promotion zone)
                          ...leaderboard.standings
                              .where((s) => s.rank <= 10)
                              .map((standing) => LeaderboardTile(standing: standing)),

                          SizedBox(height: 16.h),

                          // Demotion zone label
                          if (leaderboard.standings.any((s) => s.isDemoted)) ...[
                            _buildZoneLabel(
                              'NHÓM RỚT HẠNG',
                              AppColors.cardinal,
                              Icons.arrow_downward,
                            ),
                            SizedBox(height: 8.h),

                            // Bottom 5 (Demotion zone)
                            ...leaderboard.standings
                                .where((s) => s.isDemoted)
                                .map((standing) => LeaderboardTile(standing: standing)),
                          ],

                          // Middle zone (if not showing all)
                          if (leaderboard.standings.length > 15 &&
                              !leaderboard.standings
                                  .where((s) => !s.isPromoted && !s.isDemoted)
                                  .any((s) => s.isCurrentUser)) ...[
                            SizedBox(height: 16.h),
                            Center(
                              child: Text(
                                '...',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: AppColors.wolf,
                                ),
                              ),
                            ),
                          ] else ...[
                            // Show all middle rankings
                            ...leaderboard.standings
                                .where((s) => !s.isPromoted && !s.isDemoted)
                                .map((standing) => LeaderboardTile(standing: standing)),
                          ],

                          SizedBox(height: 24.h),
                        ],
                      ),
                    );
                  }

                  // Initial state
                  return Center(
                    child: Text(
                      'Đang tải...',
                      style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.wolf),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneLabel(String text, Color color, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20.sp),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(width: 8.w),
        Icon(icon, color: color, size: 20.sp),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.macaw, size: 32.sp),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.eel,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.wolf,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showInfoDialog(BuildContext context) {
    final bloc = context.read<LeaderboardBloc>();
    final state = bloc.state;
    
    if (state is! LeaderboardLoaded) return;
    
    final userTier = state.userTier;
    final userRank = state.leaderboard.userRank;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.snow,
        title: Text(
          'Thống kê của bạn',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.eel,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatItem('Hạng hiện tại', '${userRank ?? '-'}', Icons.emoji_events),
            SizedBox(height: 16.h),
            _buildStatItem('Tuần liên tiếp', '${userTier.consecutiveWeeks}', Icons.calendar_today),
            SizedBox(height: 16.h),
            _buildStatItem('Thăng hạng', '${userTier.totalPromotions}', Icons.trending_up),
            SizedBox(height: 24.h),
            Divider(color: AppColors.swan),
            SizedBox(height: 16.h),
            Text(
              'Cách hoạt động',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.eel,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              '• Mỗi tuần bắt đầu vào Thứ 2\n'
              '• Top 10: Thăng hạng ⬆️\n'
              '• 5 cuối: Xuống hạng ⬇️\n'
              '• Kiếm XP để leo hạng!',
              style: TextStyle(
                color: AppColors.eel,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Đóng',
              style: TextStyle(color: AppColors.macaw),
            ),
          ),
        ],
      ),
    );
  }
}
