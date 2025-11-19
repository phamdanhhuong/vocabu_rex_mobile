import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/feed/data/models/feed_post_model.dart';
import 'package:vocabu_rex_mobile/feed/ui/utils/feed_constants.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class FeedPostCard extends StatefulWidget {
  final FeedPostModel post;
  final String? currentUserId;
  final Function(String) onReaction;
  final VoidCallback onComment;
  final VoidCallback? onDelete;
  final VoidCallback? onUserTap;
  final VoidCallback onViewReactions;
  final VoidCallback onViewComments;
  final Function(String) onQuickComment;

  const FeedPostCard({
    Key? key,
    required this.post,
    this.currentUserId,
    required this.onReaction,
    required this.onComment,
    this.onDelete,
    this.onUserTap,
    required this.onViewReactions,
    required this.onViewComments,
    required this.onQuickComment,
  }) : super(key: key);

  @override
  State<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() {
    if (_commentController.text.trim().isEmpty) return;
    widget.onQuickComment(_commentController.text.trim());
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final config = PostTypeConfig.getConfig(widget.post.postType);
    final bool isOwnPost = widget.currentUserId == widget.post.userId;
    final totalReactions = widget.post.reactions.fold<int>(0, (sum, r) => sum + r.count);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header: Avatar + Name + Time
            _buildHeader(config),
            
            SizedBox(height: 12.h),

            // 2. Body: Text Content (Left) + Large Image (Right)
            _buildBodyLayout(config),
            
            SizedBox(height: 20.h),

            // 3. Action Area: Big Button + Reaction Bubble
            _buildActionSection(isOwnPost, totalReactions),

            SizedBox(height: 16.h),
            Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
            SizedBox(height: 12.h),

            // 4. Footer: Quick Comment Input
            _buildFooterInput(isOwnPost),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(PostTypeConfig config) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: widget.onUserTap,
          child: CircleAvatar(
            radius: 22.r,
            backgroundColor: config.backgroundColor,
            backgroundImage: widget.post.user.profilePictureUrl != null
                ? NetworkImage(widget.post.user.profilePictureUrl!)
                : null,
            child: widget.post.user.profilePictureUrl == null
                ? Text(
                    widget.post.user.displayName[0].toUpperCase(),
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
                onTap: widget.onUserTap,
                child: Text(
                  widget.post.user.displayName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold, // Bold like image
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                _formatTimeAgo(widget.post.createdAt),
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade500, // Lighter gray for time
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBodyLayout(PostTypeConfig config) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Content Text on the Left
        Expanded(
          child: Text(
            widget.post.content,
            style: TextStyle(
              fontSize: 16.sp, // Larger text
              color: Colors.black87,
              height: 1.3,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        
        // Large Achievement Image on the Right
        // In real app, use actual image asset. Here using Config Icon as placeholder
        Container(
          width: 70.w,
          height: 70.w,
          decoration: BoxDecoration(
            color: config.backgroundColor.withOpacity(0.3),
            shape: BoxShape.circle, // Or rounded rect depending on image
          ),
          child: Icon(
            config.icon,
            size: 40.sp,
            color: config.color,
          ),
        ),
      ],
    );
  }

  Widget _buildActionSection(bool isOwnPost, int totalReactions) {
    return Row(
      children: [
        // Big "CHÚC MỪNG" Button
        Expanded(
          child: InkWell(
            onTap: () {
              if (!isOwnPost) {
                widget.onReaction(ReactionType.congrats.value);
              }
            },
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 2,
                ),
                // Optional: Add bottom border "lip" for 3D effect like Duolingo
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    offset: const Offset(0, 2),
                    blurRadius: 0,
                  )
                ]
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.celebration_rounded, // Confetti icon
                    color: isOwnPost ? Colors.grey : Colors.blueAccent,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    isOwnPost ? 'CHIA SẺ' : 'CHÚC MỪNG',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800, // Extra bold uppercase
                      color: isOwnPost ? Colors.grey : Colors.blueAccent,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        SizedBox(width: 12.w),

        // Reaction Count Bubble (Circle on the right)
        if (totalReactions > 0)
          GestureDetector(
            onTap: widget.onViewReactions,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.celebration, size: 14.sp, color: Colors.orange), // Tiny confetti
                  SizedBox(width: 2.w),
                  Text(
                    '$totalReactions',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFooterInput(bool isOwnPost) {
    final latestComment = widget.post.latestComment;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Hiển thị comment gần nhất nếu có, nếu không thì hiển thị input
        Expanded(
          child: latestComment != null
              ? GestureDetector(
                  onTap: widget.onViewComments,
                  child: Row(
                    children: [
                      Text(
                        latestComment.user.displayName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        child: Text(
                          ':',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          latestComment.content,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black87,
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
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Thêm bình luận...',
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade400,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(fontSize: 14.sp),
                        onSubmitted: (_) => _submitComment(),
                      ),
                    ),
                  ],
                ),
        ),

        // Comment Count Icon
        GestureDetector(
          onTap: widget.onViewComments,
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 18.sp,
                color: Colors.grey.shade400,
              ),
              if (widget.post.commentCount > 0) ...[
                SizedBox(width: 4.w),
                Text(
                  '${widget.post.commentCount}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade600,
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