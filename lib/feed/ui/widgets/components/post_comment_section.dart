import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/feed/domain/entities/feed_comment_entity.dart';
import 'package:vocabu_rex_mobile/feed/ui/utils/feed_tokens.dart';
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
                          fontSize: FeedTokens.fontS,
                          fontWeight: FeedTokens.fontWeightBold,
                          color: AppColors.feedTextPrimary,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: FeedTokens.spacingHorizontalM),
                        child: Text(
                          ':',
                          style: TextStyle(
                            fontWeight: FeedTokens.fontWeightBold,
                            color: AppColors.feedTextPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          latestComment!.content,
                          style: TextStyle(
                            fontSize: FeedTokens.fontS,
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
                            fontSize: FeedTokens.fontS,
                            color: AppColors.hare,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(fontSize: FeedTokens.fontS),
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
                size: FeedTokens.iconS,
                color: AppColors.hare,
              ),
              if (commentCount > 0) ...[
                SizedBox(width: FeedTokens.spacingS),
                Text(
                  '$commentCount',
                  style: TextStyle(
                    fontSize: FeedTokens.fontXs,
                    color: AppColors.feedTextSecondary,
                    fontWeight: FeedTokens.fontWeightSemiBold,
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
