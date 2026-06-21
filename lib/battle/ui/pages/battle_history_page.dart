import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/battle/ui/blocs/battle_bloc.dart';
import 'package:vocabu_rex_mobile/battle/domain/entities/battle_entities.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import 'package:intl/intl.dart';
import 'package:vocabu_rex_mobile/web/widgets/web_page_wrapper.dart';
import 'package:vocabu_rex_mobile/battle/ui/pages/battle_history_detail_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animate_do/animate_do.dart';

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
        final isDark = AppPreferences().isDarkMode;
        return WebPageWrapper(
          mobileScaffold: Scaffold(
            backgroundColor: isDark ? const Color(0xFF0F0F16) : AppColors.polar,
            appBar: AppBar(
              title: Text(
                'Bảng Phong Thần',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18.sp,
                  color: isDark ? Colors.white : AppColors.bodyText,
                  letterSpacing: 1,
                ),
              ),
              backgroundColor: isDark ? const Color(0xFF0F0F16) : AppColors.snow,
              elevation: 0,
              iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.bodyText),
              bottom: isDark ? null : PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Container(color: AppColors.swan, height: 1.0),
              ),
            ),
            body: BlocBuilder<BattleBloc, BattleState>(
              builder: (context, state) {
                if (state is BattleStatsLoaded) {
                  return _buildContent(state.stats, state.history, isDark);
                }
                return _buildSkeleton(isDark);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BattleStatsEntity stats, List<BattleHistoryEntity> history, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 768;
        return RefreshIndicator(
          color: AppColors.macaw,
          onRefresh: () async {
            context.read<BattleBloc>().add(BattleLoadStats());
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            itemCount: 2 + (history.isEmpty ? 1 : history.length), // Stats + Title + History Items
            itemBuilder: (context, index) {
              if (index == 0) {
                // Thống kê (hiện ngay)
                return FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 24.h),
                    child: _buildGladiatorStats(stats, isWide, isDark),
                  ),
                );
              } else if (index == 1) {
                // Tiêu đề
                return FadeInRight(
                  duration: const Duration(milliseconds: 500),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Text(
                      'NHẬT KÝ HUYẾT CHIẾN',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white70 : AppColors.wolf,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                );
              } else {
                // Danh sách
                if (history.isEmpty) {
                  return FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    child: _buildEmptyHistory(isDark),
                  );
                }
                final matchIndex = index - 2;
                return FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  child: _buildHistoryCard(history[matchIndex], isWide, isDark),
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildSkeleton(bool isDark) {
    final baseColor = isDark ? Colors.white12 : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.white24 : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Skeleton for Gladiator Stats
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161622) : AppColors.snow,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Column(
                children: [
                  Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(4, (index) => Column(
                      children: [
                        Container(width: 40.w, height: 20.h, color: Colors.white),
                        SizedBox(height: 4.h),
                        Container(width: 30.w, height: 10.h, color: Colors.white),
                      ],
                    )),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            
            // Skeleton for Title
            Container(width: 150.w, height: 16.h, color: Colors.white),
            SizedBox(height: 12.h),

            // Skeleton for History Cards
            ...List.generate(5, (index) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Container(
                width: double.infinity,
                height: 80.h,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161622) : AppColors.snow,
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildGladiatorStats(BattleStatsEntity stats, bool isWide, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161622) : AppColors.snow,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: isDark ? Colors.white12 : AppColors.swan, width: 2.w),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black45 : Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Win Rate Circle
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100.w,
                height: 100.w,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: stats.winRate / 100),
                  duration: const Duration(seconds: 1),
                  builder: (context, value, _) => CircularProgressIndicator(
                    value: value,
                    strokeWidth: 8.w,
                    backgroundColor: isDark ? Colors.white12 : AppColors.swan,
                    color: AppColors.macaw,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${stats.winRate.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.bodyText,
                      fontFamily: 'DuolingoFeather',
                    ),
                  ),
                  Text(
                    'Tỉ Lệ Thắng',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : AppColors.hare,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24.h),
          
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statItem('TỔNG', '${stats.totalMatches}', isDark ? Colors.white70 : AppColors.wolf, isDark),
              _statItem('THẮNG', '${stats.wins}', AppColors.featherGreen, isDark),
              _statItem('THUA', '${stats.losses}', AppColors.cardinal, isDark),
              _statItem('CHUỖI', '${stats.winStreak}', AppColors.fox, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w900,
            color: color,
            fontFamily: 'DuolingoFeather',
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: isDark ? Colors.white54 : AppColors.hare,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyHistory(bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 48.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161622) : AppColors.snow,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: isDark ? Colors.white12 : AppColors.swan, width: 2.w),
      ),
      child: Column(
        children: [
          Icon(Icons.sports_martial_arts, size: 48.sp, color: isDark ? Colors.white24 : AppColors.swan),
          SizedBox(height: 12.h),
          Text(
            'Chưa nếm mùi đao kiếm',
            style: TextStyle(color: isDark ? Colors.white70 : AppColors.hare, fontSize: 14.sp, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 4.h),
          Text(
            'Hãy bước vào Đấu Trường để lưu danh sử sách!',
            style: TextStyle(color: isDark ? Colors.white54 : AppColors.hare, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BattleHistoryEntity match, bool isWide, bool isDark) {
    final isWin = match.result == 'WIN';
    final isDraw = match.result == 'DRAW';
    final resultColor = isWin ? AppColors.featherGreen : (isDraw ? AppColors.bee : AppColors.cardinal);
    final resultText = isWin ? 'THẮNG' : (isDraw ? 'HÒA' : 'THUA');
    final resultIcon = isWin ? Icons.emoji_events : (isDraw ? Icons.handshake : Icons.close);

    final opponentName = match.opponent?.displayName ?? (match.isBot ? 'Bot' : 'Không rõ');
    final dateStr = match.completedAt != null
        ? DateFormat('dd/MM/yyyy – HH:mm').format(match.completedAt!)
        : '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                BounceInUp(
                  duration: const Duration(milliseconds: 500),
                  child: BattleHistoryDetailPage(match: match),
                ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? null : AppColors.snow,
          gradient: isDark ? LinearGradient(
            colors: [
              resultColor.withValues(alpha: 0.15),
              const Color(0xFF161622),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ) : null,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: isDark ? resultColor.withValues(alpha: 0.3) : AppColors.swan, width: 1.w),
        ),
      child: Row(
        children: [
          // Result badge (Hexagon like)
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F0F16) : resultColor.withValues(alpha: 0.15),
              border: isDark ? Border.all(color: resultColor, width: 2) : null,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: isDark ? [
                BoxShadow(color: resultColor.withValues(alpha: 0.3), blurRadius: 10),
              ] : null,
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
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.bodyText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (match.isBot)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white12 : AppColors.hare.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'BOT',
                          style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : AppColors.wolf),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  dateStr,
                  style: TextStyle(fontSize: 10.sp, color: isDark ? Colors.white54 : AppColors.hare, fontWeight: FontWeight.w600),
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
                  color: resultColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: isDark ? Border.all(color: resultColor.withValues(alpha: 0.5)) : null,
                ),
                child: Text(
                  resultText,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w900,
                    color: resultColor,
                    letterSpacing: 1,
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                '${match.myScore} - ${match.opponentScore}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.bodyText,
                  fontFamily: 'DuolingoFeather',
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
    ));
  }
}
