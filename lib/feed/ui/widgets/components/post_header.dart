import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/feed/domain/entities/feed_post_entity.dart';
import 'package:vocabu_rex_mobile/feed/ui/utils/feed_constants.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class PostHeader extends StatelessWidget {
  final FeedPostEntity post;
  final PostTypeConfig config;
  final VoidCallback? onUserTap;

  const PostHeader({
    Key? key,
    required this.post,
    required this.config,
    this.onUserTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onUserTap,
          child: CircleAvatar(
            radius: 22.r,
            backgroundColor: config.backgroundColor,
            backgroundImage: post.user.profilePictureUrl != null
                ? NetworkImage(post.user.profilePictureUrl!)
                : null,
            child: post.user.profilePictureUrl == null
                ? Text(
                    post.user.displayName[0].toUpperCase(),
                    style: TextStyle(
                      color: config.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  )
                : null,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onUserTap,
                child: Text(
                  post.user.displayName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.feedTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                _formatTimeAgo(post.createdAt),
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.feedTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} tiếng';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày';
    } else {
      return '${difference.inDays} ngày';
    }
  }
}
