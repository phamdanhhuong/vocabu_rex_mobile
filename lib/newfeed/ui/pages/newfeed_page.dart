import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

/// Trang Bảng tin (News Feed)
class NewFeedPage extends StatefulWidget {
  const NewFeedPage({Key? key}) : super(key: key);

  @override
  State<NewFeedPage> createState() => _NewFeedPageState();
}

class _NewFeedPageState extends State<NewFeedPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.polar,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: AppColors.snow,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bảng tin',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.bodyText,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.filter_list, color: AppColors.macaw, size: 24.sp),
                    onPressed: () {
                      // Show filter options
                    },
                  ),
                ],
              ),
            ),

            // Feed list
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return _buildFeedCard(context, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedCard(BuildContext context, int index) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.swan, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: AppColors.macaw.withOpacity(0.2),
                child: Icon(Icons.person, color: AppColors.macaw, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Người dùng ${index + 1}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.bodyText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${index + 1} giờ trước',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.wolf,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.more_horiz, color: AppColors.wolf, size: 24.sp),
                onPressed: () {},
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Achievement card
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.featherGreen.withOpacity(0.1),
                  AppColors.macaw.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.featherGreen, width: 2.w),
            ),
            child: Row(
              children: [
                Icon(Icons.emoji_events, color: AppColors.bee, size: 40.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đã hoàn thành streak 7 ngày! 🎉',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.bodyText,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Tiếp tục phát huy nhé!',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.wolf,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Actions
          Row(
            children: [
              _buildActionButton(Icons.thumb_up_outlined, '${index * 3 + 5}', AppColors.macaw),
              SizedBox(width: 16.w),
              _buildActionButton(Icons.chat_bubble_outline, '${index + 2}', AppColors.wolf),
              SizedBox(width: 16.w),
              _buildActionButton(Icons.share_outlined, 'Chia sẻ', AppColors.wolf),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20.sp),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
