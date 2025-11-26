import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/quest/domain/entities/user_quest_entity.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/quest_bloc.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/quest_event.dart';

const Color _questGold = Color(0xFFFFD700);
const Color _questPurple = Color(0xFF9C27B0);

class MonthlyBadgeCard extends StatelessWidget {
  final UserQuestEntity userQuest;
  final String? isClaimingId;

  const MonthlyBadgeCard({
    Key? key,
    required this.userQuest,
    this.isClaimingId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCompleted = userQuest.isCompleted;
    final canClaim = userQuest.canClaim;
    final isClaiming = isClaimingId == userQuest.questId;
    
    // Calculate remaining time
    final now = DateTime.now();
    final remaining = userQuest.endDate.difference(now);
    final days = remaining.inDays;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _questPurple.withOpacity(0.15),
            _questGold.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted ? _questGold : _questPurple.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _questPurple.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Badge Icon
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      _questGold.withOpacity(0.3),
                      _questPurple.withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              if (userQuest.quest.badgeIconUrl != null)
                ClipOval(
                  child: Image.network(
                    userQuest.quest.badgeIconUrl!,
                    width: 80.w,
                    height: 80.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildDefaultBadgeIcon(),
                  ),
                )
              else
                _buildDefaultBadgeIcon(),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Badge Title
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _questPurple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'HUY HIỆU THÁNG ${userQuest.endDate.month}',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: _questPurple,
                letterSpacing: 1,
              ),
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // Quest Name
          Text(
            userQuest.quest.name,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.bodyText,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 8.h),
          
          // Description
          if (userQuest.quest.description.isNotEmpty)
            Text(
              userQuest.quest.description,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          
          SizedBox(height: 16.h),
          
          // Time Remaining
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _questPurple.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time, color: _questPurple, size: 18.w),
                SizedBox(width: 8.w),
                Text(
                  'Còn $days ngày',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: _questPurple,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 20.h),
          
          // Progress Section
          _buildProgressSection(),
          
          SizedBox(height: 20.h),
          
          // Difficulty Badge
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: _getDifficultyColor(userQuest.difficultyLevel).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getDifficultyColor(userQuest.difficultyLevel),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.trending_up,
                  color: _getDifficultyColor(userQuest.difficultyLevel),
                  size: 20.w,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Độ khó: ${_getDifficultyLabel(userQuest.difficultyLevel)}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: _getDifficultyColor(userQuest.difficultyLevel),
                  ),
                ),
              ],
            ),
          ),
          
          if (canClaim || isCompleted) ...[
            SizedBox(height: 20.h),
            if (canClaim)
              _buildClaimButton(context, isClaiming)
            else if (isCompleted)
              _buildCompletedBadge(),
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultBadgeIcon() {
    return Container(
      width: 80.w,
      height: 80.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_questGold, _questPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.emoji_events,
        color: Colors.white,
        size: 48.w,
      ),
    );
  }

  Widget _buildProgressSection() {
    final progress = userQuest.progressPercentage;
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tiến độ hoàn thành',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: _questPurple,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                userQuest.isCompleted ? _questGold : _questPurple,
              ),
              minHeight: 12.h,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '${userQuest.progress} / ${userQuest.requirement}',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimButton(BuildContext context, bool isClaiming) {
    return Container(
      width: double.infinity,
      height: 50.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_questGold, _questPurple],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _questPurple.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isClaiming
            ? null
            : () {
                context.read<QuestBloc>().add(ClaimQuestEvent(userQuest.questId));
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isClaiming
            ? SizedBox(
                width: 24.w,
                height: 24.w,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events, size: 24.w),
                  SizedBox(width: 8.w),
                  Text(
                    'Nhận huy hiệu',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCompletedBadge() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified, color: Colors.green, size: 24.w),
          SizedBox(width: 8.w),
          Text(
            'Đã nhận huy hiệu',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'VERY_EASY':
        return Colors.green[400]!;
      case 'EASY':
        return Colors.green[600]!;
      case 'MEDIUM':
        return Colors.orange[500]!;
      case 'HARD':
        return Colors.red[500]!;
      case 'VERY_HARD':
        return Colors.red[800]!;
      default:
        return Colors.grey;
    }
  }

  String _getDifficultyLabel(String difficulty) {
    switch (difficulty) {
      case 'VERY_EASY':
        return 'Rất dễ';
      case 'EASY':
        return 'Dễ';
      case 'MEDIUM':
        return 'Trung bình';
      case 'HARD':
        return 'Khó';
      case 'VERY_HARD':
        return 'Rất khó';
      default:
        return difficulty;
    }
  }
}
