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
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.transparent,
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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(_questPurple),
                        minHeight: 32.h,
                      ),
                    ),
                    // Progress text overlaid on the bar
                    Text(
                      '${userQuest.progress} / ${userQuest.requirement}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: progress > 0.5 ? Colors.white : AppColors.eel,
                        shadows: progress > 0.5 ? [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ] : null,
                      ),
                    ),
                  ],
                ),
              ),
              // Chest icon
              _buildChestIcon(chestType, userQuest.isCompleted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChestIcon(dynamic chestType, bool isCompleted) {
    // Determine chest type
    String chestTypeName = 'bronze'; // default
    
    if (chestType != null) {
      final typeStr = chestType.toString().toLowerCase();
      if (typeStr.contains('bronze')) {
        chestTypeName = 'bronze';
      } else if (typeStr.contains('silver')) {
        chestTypeName = 'silver';
      } else if (typeStr.contains('gold')) {
        chestTypeName = 'gold';
      } else if (typeStr.contains('friend')) {
        chestTypeName = 'friend';
      }
    }
    
    // Determine state (open or close)
    String state = isCompleted ? 'open' : 'close';
    
    // Build image path
    String imagePath = 'assets/icons/chest_${chestTypeName}_$state.png';
    
    return Container(
      width: 48.w,
      height: 48.w,
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to icon if image not found
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.inventory_2,
              color: isCompleted ? Colors.amber[700] : Colors.grey[600],
              size: 28.w,
            ),
          );
        },
      ),
    );
  }
}
