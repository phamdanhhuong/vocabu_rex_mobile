import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/battle/ui/blocs/battle_bloc.dart';
import 'package:vocabu_rex_mobile/battle/domain/entities/battle_entities.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import 'package:intl/intl.dart';
import 'package:vocabu_rex_mobile/web/widgets/web_page_wrapper.dart';

class BattleHistoryPage extends StatefulWidget {
  const BattleHistoryPage({super.key});

  @override
  State<BattleHistoryPage> createState() => _BattleHistoryPageState();
}

class _BattleHistoryPageState extends State<BattleHistoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<BattleBloc>().add(BattleLoadStats());
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppPreferences(),
      builder: (context, _) {
        return WebPageWrapper(
          mobileScaffold: Scaffold(
            backgroundColor: AppColors.polar,
            appBar: AppBar(
              title: Text(
                'Lịch sử đấu',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                  color: AppColors.bodyText,
                ),
              ),
              backgroundColor: AppColors.snow,
              elevation: 0,
              iconTheme: IconThemeData(color: AppColors.bodyText),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Container(color: AppColors.swan, height: 1.0),
              ),
            ),
            body: BlocBuilder<BattleBloc, BattleState>(
              builder: (context, state) {
                if (state is BattleStatsLoaded) {
                  return _buildContent(state.stats, state.history);
                }
                return Center(
                  child: CircularProgressIndicator(color: AppColors.macaw),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BattleStatsEntity stats, List<BattleHistoryEntity> history) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 768;
        return RefreshIndicator(
          color: AppColors.macaw,
          onRefresh: () async {
            context.read<BattleBloc>().add(BattleLoadStats());
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats summary row
                _buildStatsSummary(stats, isWide),
                SizedBox(height: 20.h),

                // History list
                Text(
                  'Lịch sử trận đấu',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.bodyText,
                  ),
                ),
                SizedBox(height: 12.h),

                if (history.isEmpty)
                  _buildEmptyHistory()
                else
                  ...history.map((match) => _buildHistoryCard(match, isWide)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsSummary(BattleStatsEntity stats, bool isWide) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.swan, width: 2.w),
      ),
      child: isWide
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _buildStatsItems(stats),
            )
          : Wrap(
              alignment: WrapAlignment.spaceAround,
              runSpacing: 16.h,
              children: _buildStatsItems(stats),
            ),
    );
  }

  List<Widget> _buildStatsItems(BattleStatsEntity stats) {
    return [
      _statItem('Tổng trận', '${stats.totalMatches}', AppColors.macaw),
      _statItem('Thắng', '${stats.wins}', AppColors.featherGreen),
      _statItem('Thua', '${stats.losses}', AppColors.cardinal),
      _statItem('Hòa', '${stats.draws}', AppColors.bee),
      _statItem('Tỉ lệ thắng', '${stats.winRate.toStringAsFixed(0)}%', AppColors.beetle),
      _statItem('Chuỗi thắng', '${stats.bestWinStreak}', AppColors.fox),
    ];
  }

  Widget _statItem(String label, String value, Color color) {
    return SizedBox(
      width: 80.w,
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.wolf,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 48.h),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.swan, width: 2.w),
      ),
      child: Column(
        children: [
          Icon(Icons.sports_esports_outlined, size: 48.sp, color: AppColors.swan),
          SizedBox(height: 12.h),
          Text(
            'Chưa có trận đấu nào',
            style: TextStyle(color: AppColors.hare, fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4.h),
          Text(
            'Hãy bắt đầu thi đấu để xem lịch sử!',
            style: TextStyle(color: AppColors.hare, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BattleHistoryEntity match, bool isWide) {
    final isWin = match.result == 'WIN';
    final isDraw = match.result == 'DRAW';
    final resultColor = isWin ? AppColors.featherGreen : (isDraw ? AppColors.bee : AppColors.cardinal);
    final resultText = isWin ? 'THẮNG' : (isDraw ? 'HÒA' : 'THUA');
    final resultIcon = isWin ? Icons.emoji_events : (isDraw ? Icons.handshake : Icons.close);

    final opponentName = match.opponent?.displayName ?? (match.isBot ? 'Bot' : 'Không rõ');
    final dateStr = match.completedAt != null
        ? DateFormat('dd/MM/yyyy – HH:mm').format(match.completedAt!)
        : '';

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.swan, width: 2.w),
      ),
      child: Row(
        children: [
          // Result badge
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: resultColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(resultIcon, color: resultColor, size: 24.sp),
          ),
          SizedBox(width: 14.w),

          // Match details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'vs $opponentName',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.bodyText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (match.isBot)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.hare.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'BOT',
                          style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: AppColors.wolf),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  dateStr,
                  style: TextStyle(fontSize: 11.sp, color: AppColors.hare),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),

          // Score & result
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: resultColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  resultText,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: resultColor,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '${match.myScore} - ${match.opponentScore}',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.bodyText,
                ),
              ),
              if (match.xpEarned > 0) ...[
                SizedBox(height: 2.h),
                Text(
                  '+${match.xpEarned} XP',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.featherGreen,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
