import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/feed/data/models/feed_post_model.dart';
import 'package:vocabu_rex_mobile/feed/ui/utils/feed_constants.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class FeedPostCard extends StatelessWidget {
  final FeedPostModel post;
  final String? currentUserId;
  final Function(String) onReaction;
  final VoidCallback onComment;
  final VoidCallback? onDelete;
  final VoidCallback? onUserTap;

  const FeedPostCard({
    Key? key,
    required this.post,
    this.currentUserId,
    required this.onReaction,
    required this.onComment,
    this.onDelete,
    this.onUserTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = PostTypeConfig.getConfig(post.postType);
    final bool isOwnPost = currentUserId == post.userId;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      color: AppColors.feedCardBackground,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: User info + timestamp
            _buildHeader(config, isOwnPost),
            SizedBox(height: 12.h),

            // Post content
            _buildContent(config),
            SizedBox(height: 16.h),

            // Reactions summary
            if (post.reactions.isNotEmpty) ...[
              _buildReactionsSummary(),
              SizedBox(height: 12.h),
            ],

            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(PostTypeConfig config, bool isOwnPost) {
    return Row(
      children: [
        // Avatar
        GestureDetector(
          onTap: onUserTap,
          child: CircleAvatar(
            radius: 20.r,
            backgroundImage: post.user.profilePictureUrl != null
                ? NetworkImage(post.user.profilePictureUrl!)
                : null,
            backgroundColor: config.backgroundColor,
            child: post.user.profilePictureUrl == null
                ? Text(
                    post.user.displayName[0].toUpperCase(),
                    style: TextStyle(
                      color: config.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  )
                : null,
          ),
        ),
        SizedBox(width: 12.w),

        // User info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onUserTap,
                child: Row(
                  children: [
                    Text(
                      post.user.displayName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.feedTextPrimary,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: config.backgroundColor,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        'Lv ${post.user.currentLevel}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: config.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                _formatTimeAgo(post.createdAt),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.feedTextSecondary,
                ),
              ),
            ],
          ),
        ),

        // Delete button (only for own posts)
        if (isOwnPost && onDelete != null)
          IconButton(
            icon: Icon(Icons.more_vert, size: 20.sp),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }

  Widget _buildContent(PostTypeConfig config) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(
            config.icon,
            color: config.color,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              post.content,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.feedTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionsSummary() {
    return Wrap(
      spacing: 8.w,
      children: post.reactions.map((reaction) {
        final reactionType = ReactionType.fromString(reaction.reactionType);
        if (reactionType == null) return const SizedBox.shrink();

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.feedDivider,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                reactionType.emoji,
                style: TextStyle(fontSize: 14.sp),
              ),
              SizedBox(width: 4.w),
              Text(
                '${reaction.count}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.feedTextPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Reaction button
        Expanded(
          child: _ActionButton(
            icon: Icons.emoji_emotions_outlined,
            label: 'Reaction',
            isActive: post.userReaction != null,
            onTap: () => _showReactionPicker(),
          ),
        ),

        // Comment button
        Expanded(
          child: _ActionButton(
            icon: Icons.comment_outlined,
            label: 'Bình luận',
            count: post.commentCount,
            onTap: onComment,
          ),
        ),
      ],
    );
  }

  void _showReactionPicker() {
    // This will be implemented as a bottom sheet in the parent
    // For now, just toggle the first reaction type
    onReaction(ReactionType.congrats.value);
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} tuần trước';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    } else {
      return '${(difference.inDays / 365).floor()} năm trước';
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? count;
  final bool isActive;
  final VoidCallback onTap;

  const _ActionButton({
    Key? key,
    required this.icon,
    required this.label,
    this.count,
    this.isActive = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18.sp,
              color: isActive ? AppColors.feedReactionActive : AppColors.feedReactionInactive,
            ),
            SizedBox(width: 6.w),
            Text(
              count != null && count! > 0 ? '$label ($count)' : label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: isActive ? AppColors.feedReactionActive : AppColors.feedTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
