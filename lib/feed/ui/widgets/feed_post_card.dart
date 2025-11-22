import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/feed/domain/entities/feed_post_entity.dart';
import 'package:vocabu_rex_mobile/feed/domain/enums/feed_enums.dart';
import 'package:vocabu_rex_mobile/feed/ui/utils/feed_constants.dart';
import 'package:vocabu_rex_mobile/feed/ui/widgets/components/post_header.dart';
import 'package:vocabu_rex_mobile/feed/ui/widgets/components/post_body.dart';
import 'package:vocabu_rex_mobile/feed/ui/widgets/components/post_reaction_button.dart';
import 'package:vocabu_rex_mobile/feed/ui/widgets/components/post_reaction_count.dart';
import 'package:vocabu_rex_mobile/feed/ui/widgets/components/post_comment_section.dart';
import 'package:vocabu_rex_mobile/feed/ui/widgets/components/reaction_overlay.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class FeedPostCard extends StatefulWidget {
  final FeedPostEntity post;
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
  final GlobalKey _reactionButtonKey = GlobalKey();

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
    final hasReacted = widget.post.userReaction != null;
    final userReactionType = hasReacted 
        ? (ReactionType.fromString(widget.post.userReaction!) ?? ReactionType.congrats)
        : ReactionType.congrats;
    
    // Lấy các reaction types khác nhau
    final reactionTypes = widget.post.reactions
        .where((r) => r.count > 0)
        .map((r) => ReactionType.fromString(r.reactionType))
        .whereType<ReactionType>()
        .toList();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.feedCardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.feedDivider, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.swan.withOpacity(0.3),
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
            PostHeader(
              post: widget.post,
              config: config,
              onUserTap: widget.onUserTap,
            ),
            
            SizedBox(height: 12.h),

            // 2. Body: Text Content (Left) + Large Image (Right)
            PostBody(
              content: widget.post.content,
              config: config,
            ),
            
            SizedBox(height: 20.h),

            // 3. Action Area: Big Button + Reaction Bubble
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PostReactionButton(
                  hasReacted: hasReacted,
                  isOwnPost: isOwnPost,
                  userReactionType: userReactionType,
                  buttonKey: _reactionButtonKey,
                  onTap: !isOwnPost 
                      ? () => widget.onReaction(ReactionType.congrats.value)
                      : null,
                  onLongPress: !isOwnPost
                      ? () => ReactionOverlay.show(
                            context: context,
                            buttonKey: _reactionButtonKey,
                            onReactionSelected: widget.onReaction,
                          )
                      : null,
                ),
                PostReactionCount(
                  totalReactions: totalReactions,
                  reactionTypes: reactionTypes,
                  onTap: widget.onViewReactions,
                ),
              ],
            ),

            SizedBox(height: 12.h),
            Divider(height: 1, thickness: 1, color: AppColors.feedDivider),
            SizedBox(height: 12.h),

            // 4. Footer: Quick Comment Input
            PostCommentSection(
              latestComment: widget.post.latestComment,
              commentCount: widget.post.commentCount,
              commentController: _commentController,
              onViewComments: widget.onViewComments,
              onSubmitComment: _submitComment,
            ),
          ],
        ),
      ),
    );
  }
}