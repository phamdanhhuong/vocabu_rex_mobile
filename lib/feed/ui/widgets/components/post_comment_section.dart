import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/feed/domain/entities/feed_comment_entity.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class PostCommentSection extends StatelessWidget {
  final FeedCommentEntity? latestComment;
  final int commentCount;
  final TextEditingController commentController;
  final VoidCallback onViewComments;
  final VoidCallback onSubmitComment;

  const PostCommentSection({
    Key? key,
    this.latestComment,
    required this.commentCount,
    required this.commentController,
    required this.onViewComments,
    required this.onSubmitComment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Hiển thị comment gần nhất nếu có, nếu không thì hiển thị input
        Expanded(
          child: latestComment != null
              ? GestureDetector(
                  onTap: onViewComments,
                  child: Row(
                    children: [
                      Text(
                        latestComment!.user.displayName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.feedTextPrimary,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        child: Text(
                          ':',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.feedTextPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          latestComment!.content,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.feedTextPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          hintText: 'Thêm bình luận...',
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.hare,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(fontSize: 14.sp),
                        onSubmitted: (_) => onSubmitComment(),
                      ),
                    ),
                  ],
                ),
        ),

        // Comment Count Icon
        GestureDetector(
          onTap: onViewComments,
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 18.sp,
                color: AppColors.hare,
              ),
              if (commentCount > 0) ...[
                SizedBox(width: 4.w),
                Text(
                  '$commentCount',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.feedTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }
}
