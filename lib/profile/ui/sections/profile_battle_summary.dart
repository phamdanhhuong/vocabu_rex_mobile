import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/battle/ui/blocs/battle_bloc.dart';
import 'package:vocabu_rex_mobile/battle/domain/entities/battle_entities.dart';
import 'package:vocabu_rex_mobile/battle/ui/pages/battle_history_page.dart';

/// Summary card shown on the Profile page. Shows last 3 battle results
/// and a tap target to open the full BattleHistoryPage.
class ProfileBattleSummary extends StatefulWidget {
  const ProfileBattleSummary({super.key});

  @override
  State<ProfileBattleSummary> createState() => _ProfileBattleSummaryState();
}

class _ProfileBattleSummaryState extends State<ProfileBattleSummary> {
  @override
  void initState() {
    super.initState();
    // Only load if not already loaded (BattlePage may have loaded it earlier)
    final state = context.read<BattleBloc>().state;
    if (state is! BattleStatsLoaded) {
      context.read<BattleBloc>().add(BattleLoadStats());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Lắng nghe Theme thay đổi
    return BlocBuilder<BattleBloc, BattleState>(
      builder: (context, state) {
        BattleStatsEntity? stats;
        List<BattleHistoryEntity> history = [];

        if (state is BattleStatsLoaded) {
          stats = state.stats;
          history = state.history;
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const BattleHistoryPage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                        .chain(CurveTween(curve: Curves.easeOut));
                    return SlideTransition(position: animation.drive(tween), child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 320),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.snow,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.swan, width: 2.w),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  if (stats != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _miniStat('Trận', '${stats.totalMatches}', AppColors.macaw),
                        _miniStat('Thắng', '${stats.wins}', AppColors.featherGreen),
                        _miniStat('Thua', '${stats.losses}', AppColors.cardinal),
                        _miniStat('Tỉ lệ', '${stats.winRate.toStringAsFixed(0)}%', AppColors.beetle),
                      ],
                    ),
                    if (history.isNotEmpty) ...[
                      Divider(color: AppColors.swan, height: 24.h),
                      // Recent matches
                      ...history.take(3).map(_buildMiniMatch),
                    ],
                  ] else
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: Text(
                          'Đang tải...',
                          style: TextStyle(color: AppColors.hare, fontSize: 13.sp),
                        ),
                      ),
                    ),

                  // "Xem tất cả" hint
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Xem tất cả lịch sử',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.macaw,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(Icons.chevron_right, color: AppColors.macaw, size: 16.sp),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: color),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: AppColors.wolf, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildMiniMatch(BattleHistoryEntity match) {
    final isWin = match.result == 'WIN';
    final isDraw = match.result == 'DRAW';
    final resultColor = isWin ? AppColors.featherGreen : (isDraw ? AppColors.bee : AppColors.cardinal);
    final resultText = isWin ? 'Thắng' : (isDraw ? 'Hòa' : 'Thua');
    final opponentName = match.opponent?.displayName ?? (match.isBot ? 'Bot' : '???');

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(color: resultColor, shape: BoxShape.circle),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'vs $opponentName',
              style: TextStyle(fontSize: 13.sp, color: AppColors.bodyText, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${match.myScore} - ${match.opponentScore}',
            style: TextStyle(fontSize: 12.sp, color: AppColors.bodyText, fontWeight: FontWeight.w700),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: resultColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              resultText,
              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: resultColor),
            ),
          ),
        ],
      ),
    );
  }
}
