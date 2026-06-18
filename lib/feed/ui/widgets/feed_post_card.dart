import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/feed/domain/entities/feed_post_entity.dart';
import 'package:vocabu_rex_mobile/feed/domain/enums/feed_enums.dart';
import 'package:vocabu_rex_mobile/feed/ui/utils/feed_constants.dart';
import 'package:vocabu_rex_mobile/feed/ui/utils/feed_tokens.dart';
import 'package:vocabu_rex_mobile/feed/ui/widgets/components/post_header.dart';
import 'package:vocabu_rex_mobile/feed/ui/widgets/components/post_body.dart';
import 'package:vocabu_rex_mobile/feed/ui/widgets/components/post_reaction_button.dart';
import 'package:vocabu_rex_mobile/feed/ui/widgets/components/post_reaction_count.dart';
import 'package:vocabu_rex_mobile/feed/ui/widgets/components/post_comment_section.dart';
import 'package:vocabu_rex_mobile/feed/ui/widgets/components/reaction_overlay.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:share_plus/share_plus.dart';
import 'package:animate_do/animate_do.dart';

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
    super.key,
    required this.post,
    this.currentUserId,
    required this.onReaction,
    required this.onComment,
    this.onDelete,
    this.onUserTap,
    required this.onViewReactions,
    required this.onViewComments,
    required this.onQuickComment,
  });

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

  Widget _buildSpecialSticker(String type) {
    String emoji;
    Widget Function(Widget) animator = (child) => child;

    if (type == PostType.streakMilestone.value) {
      emoji = '🔥';
      animator = (child) => Pulse(infinite: true, child: child);
    } else if (type == PostType.leaguePromotion.value || type == PostType.leagueTop3.value) {
      emoji = '🏆';
      animator = (child) => Tada(infinite: true, duration: const Duration(seconds: 3), child: child);
    } else if (type == PostType.xpMilestone.value || type == PostType.levelUp.value) {
      emoji = '⚡';
      animator = (child) => Flash(infinite: true, duration: const Duration(seconds: 3), child: child);
    } else if (type == PostType.perfectScore.value) {
      emoji = '⭐';
      animator = (child) => Spin(infinite: true, duration: const Duration(seconds: 4), child: child);
    } else if (type == PostType.achievementUnlocked.value) {
      emoji = '🏅';
      animator = (child) => Bounce(infinite: true, duration: const Duration(seconds: 2), child: child);
    } else {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: FeedTokens.cardMarginVertical - 15,
      right: FeedTokens.cardMarginHorizontal - 10,
      child: Transform.rotate(
        angle: 0.2,
        child: animator(
          Text(
            emoji,
            style: const TextStyle(
              fontSize: 48,
              shadows: [Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(2, 2))],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _getSpecialDecoration(String type) {
    Color primary;
    Color secondary;
    
    if (type == PostType.streakMilestone.value) {
      primary = AppColors.cardinal;
      secondary = AppColors.fox;
    } else if (type == PostType.leaguePromotion.value || type == PostType.leagueTop3.value) {
      primary = AppColors.bee;
      secondary = Colors.purple;
    } else if (type == PostType.xpMilestone.value || type == PostType.levelUp.value) {
      primary = AppColors.macaw;
      secondary = Colors.cyan;
    } else if (type == PostType.perfectScore.value) {
      primary = AppColors.featherGreen;
      secondary = AppColors.maskGreen;
    } else if (type == PostType.achievementUnlocked.value) {
      primary = Colors.pinkAccent;
      secondary = Colors.purpleAccent;
    } else {
      return BoxDecoration(
        color: AppColors.feedCardBackground,
        borderRadius: BorderRadius.circular(FeedTokens.radiusM),
        border: Border.all(color: AppColors.feedDivider, width: FeedTokens.borderMedium),
        boxShadow: [
          BoxShadow(
            color: AppColors.swan.withOpacity(FeedTokens.shadowOpacityMedium),
            blurRadius: FeedTokens.elevationLow,
            offset: const Offset(0, 2),
          ),
        ],
      );
    }

    return BoxDecoration(
      color: AppColors.snow,
      borderRadius: BorderRadius.circular(FeedTokens.radiusM),
      border: Border.all(color: primary, width: 2.0),
      boxShadow: [
        BoxShadow(
          color: primary.withOpacity(0.4),
          blurRadius: 15,
          spreadRadius: 2,
          offset: const Offset(0, 2),
        ),
      ],
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primary.withOpacity(0.15),
          AppColors.snow,
          secondary.withOpacity(0.05),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = PostTypeConfig.getConfig(widget.post.postType);
    final bool isOwnPost = widget.currentUserId == widget.post.userId;
    final totalReactions = widget.post.reactions.fold<int>(
      0,
      (sum, r) => sum + r.count,
    );
    final hasReacted = widget.post.userReaction != null;
    final userReactionType = hasReacted
        ? (ReactionType.fromString(widget.post.userReaction!) ??
              ReactionType.congrats)
        : ReactionType.congrats;

    // Lấy các reaction types khác nhau
    final reactionTypes = widget.post.reactions
        .where((r) => r.count > 0)
        .map((r) => ReactionType.fromString(r.reactionType))
        .whereType<ReactionType>()
        .toList();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: FeedTokens.cardMarginHorizontal,
            vertical: FeedTokens.cardMarginVertical,
          ),
          decoration: _getSpecialDecoration(widget.post.postType),
          child: Padding(
        padding: EdgeInsets.all(FeedTokens.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header: Avatar + Name + Time
            PostHeader(
              post: widget.post,
              config: config,
              onUserTap: widget.onUserTap,
            ),

            SizedBox(height: FeedTokens.spacingL),

            // 2. Body: Text Content (Left) + Large Image (Right)
            PostBody(content: widget.post.content, config: config),

            SizedBox(height: FeedTokens.spacingXxl),

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
                      : () {
                          final text = widget.post.content.isNotEmpty 
                              ? '${widget.post.content}\n\nXem trên VocabuRex tại: http://213.35.101.223:8080/'
                              : 'Xem tin mới của tôi trên VocabuRex nè!\nTruy cập ngay tại: http://213.35.101.223:8080/';
                          Share.share(text);
                        },
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

            SizedBox(height: FeedTokens.spacingL),
            Divider(
              height: FeedTokens.borderThin,
              thickness: FeedTokens.borderThin,
              color: AppColors.feedDivider,
            ),
            SizedBox(height: FeedTokens.spacingL),

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
    ),
    _buildSpecialSticker(widget.post.postType),
      ],
    );
  }
}
