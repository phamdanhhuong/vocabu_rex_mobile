import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/quest/domain/entities/user_quest_entity.dart';

const Color _questPurple = Color(0xFF7032B3);

class DailyQuestCard extends StatelessWidget {
  final UserQuestEntity userQuest;
  final String? isClaimingId;

  const DailyQuestCard({
    Key? key,
    required this.userQuest,
    this.isClaimingId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chestType = userQuest.quest.chestType;
    final progress = userQuest.progressPercentage;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quest name
          Text(
            userQuest.quest.name,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.bodyText,
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // Progress bar with chest icon
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(_questPurple),
                    minHeight: 24.h,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // Chest icon
              _buildChestIcon(chestType),
            ],
          ),
          
          SizedBox(height: 8.h),
          
          // Progress text
          Text(
            '${userQuest.progress} / ${userQuest.requirement}',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChestIcon(dynamic chestType) {
    Color chestColor;
    
    if (chestType == null) {
      chestColor = Colors.grey;
    } else {
      final typeStr = chestType.toString();
      if (typeStr.contains('bronze')) {
        chestColor = Colors.brown[600]!;
      } else if (typeStr.contains('silver')) {
        chestColor = Colors.grey[600]!;
      } else if (typeStr.contains('gold')) {
        chestColor = Colors.amber[700]!;
      } else {
        chestColor = Colors.grey;
      }
    }
    
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: chestColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.inventory_2,
        color: chestColor,
        size: 24.w,
      ),
    );
  }
}
