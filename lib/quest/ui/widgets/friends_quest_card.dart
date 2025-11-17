import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/quest/domain/entities/user_quest_entity.dart';

const Color _questPurple = Color(0xFF7032B3);

class FriendsQuestCard extends StatelessWidget {
  final UserQuestEntity userQuest;
  final String? isClaimingId;

  const FriendsQuestCard({
    Key? key,
    required this.userQuest,
    this.isClaimingId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = userQuest.progressPercentage;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Three avatars section
          SizedBox(
            height: 100.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Left silhouette
                Positioned(
                  left: 40.w,
                  child: _buildSilhouette(Colors.grey[400]!),
                ),
                // Center egg (green mascot)
                Positioned(
                  child: _buildCenterEgg(),
                ),
                // Right silhouette
                Positioned(
                  right: 40.w,
                  child: _buildSilhouette(Colors.purple[400]!),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Target progress
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đạt được ${userQuest.requirement} KN',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.bodyText,
                  ),
                ),
                SizedBox(height: 12.h),
                
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(_questPurple),
                    minHeight: 20.h,
                  ),
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
                
                SizedBox(height: 16.h),
                
                // Participants info (placeholder - will be populated from backend)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.group, size: 16.w, color: _questPurple),
                      SizedBox(width: 8.w),
                      Text(
                        'Danh sách thành viên',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: _questPurple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 16.h),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Remind action
                        },
                        icon: Icon(Icons.waving_hand, size: 20.w),
                        label: Text(
                          'NHẮC NHẸ',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(color: Colors.grey[300]!),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Gift action
                        },
                        icon: Icon(Icons.card_giftcard, size: 20.w),
                        label: Text(
                          'TẶNG QUÀ',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(color: Colors.grey[300]!),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
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
  }

  Widget _buildSilhouette(Color color) {
    return Container(
      width: 60.w,
      height: 60.w,
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        color: color,
        size: 40.w,
      ),
    );
  }

  Widget _buildCenterEgg() {
    return Container(
      width: 80.w,
      height: 80.w,
      decoration: BoxDecoration(
        color: Colors.green[400],
        borderRadius: BorderRadius.circular(40.w),
        border: Border.all(color: Colors.yellow[700]!, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.face,
          color: Colors.white,
          size: 50.w,
        ),
      ),
    );
  }
}
