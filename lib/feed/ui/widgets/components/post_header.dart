import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/feed/domain/entities/feed_post_entity.dart';
import 'package:vocabu_rex_mobile/feed/ui/utils/feed_constants.dart';
import 'package:vocabu_rex_mobile/feed/ui/utils/feed_tokens.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/profile/ui/pages/public_profile_page.dart';
import 'package:vocabu_rex_mobile/profile/ui/widgets/avatar_display.dart';

class PostHeader extends StatelessWidget {
  final FeedPostEntity post;
  final PostTypeConfig config;
  final VoidCallback? onUserTap;

  const PostHeader({
    super.key,
    required this.post,
    required this.config,
    this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onUserTap ?? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PublicProfilePage(
                  userId: post.user.id,
                  userName: post.user.displayName,
                ),
              ),
            );
          },
          child: AvatarDisplay(
            avatarString: post.user.profilePictureUrl,
            frameId: post.user.equippedFrameId,
            backgroundId: post.user.equippedBackgroundId,
            radius: FeedTokens.avatarM,
          ),
        ),
        SizedBox(width: FeedTokens.spacingL),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onUserTap ?? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PublicProfilePage(
                        userId: post.user.id,
                        userName: post.user.displayName,
                      ),
                    ),
                  );
                },
                child: Text(
                  post.user.displayName,
                  style: TextStyle(
                    fontSize: FeedTokens.fontL,
                    fontWeight: FeedTokens.fontWeightBold,
                    color: AppColors.feedTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: FeedTokens.spacingXs),
              Text(
                _formatTimeAgo(post.createdAt),
                style: TextStyle(
                  fontSize: FeedTokens.fontXs,
                  color: AppColors.feedTextSecondary,
                  fontWeight: FeedTokens.fontWeightMedium,
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
