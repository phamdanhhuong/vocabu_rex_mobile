import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/battle/data/services/battle_api_service.dart';
import 'package:vocabu_rex_mobile/battle/domain/entities/battle_entities.dart';

/// Summary card shown on the Public Profile page. 
/// Shows last 3 battle results of that user.
/// If the user has hidden their history, it will return empty.
class PublicProfileBattleSummary extends StatefulWidget {
  final String userId;

  const PublicProfileBattleSummary({super.key, required this.userId});

  @override
  State<PublicProfileBattleSummary> createState() => _PublicProfileBattleSummaryState();
}

class _PublicProfileBattleSummaryState extends State<PublicProfileBattleSummary> {
  bool _isLoading = true;
  List<BattleHistoryEntity> _history = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final apiService = BattleApiService();
      final historyData = await apiService.getPublicHistory(widget.userId, limit: 3);
      
      if (mounted) {
        setState(() {
          _history = historyData.map((e) => BattleHistoryEntity.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Container(
          height: 100.h,
          decoration: BoxDecoration(
            color: AppColors.snow,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.swan, width: 2.w),
          ),
          child: Center(
            child: SizedBox(
              width: 24.w,
              height: 24.w,
              child: CircularProgressIndicator(strokeWidth: 2.w, color: AppColors.macaw),
            ),
          ),
        ),
      );
    }

    if (_history.isEmpty) {
      return const SizedBox.shrink(); // Hide if no history or user chose to hide it
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
            Text(
              'Lịch sử đấu gần đây',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.bodyText,
              ),
            ),
            SizedBox(height: 12.h),
            ..._history.map(_buildMiniMatch),
          ],
        ),
      ),
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
