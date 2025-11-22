import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/feed/domain/enums/feed_enums.dart';
import 'package:vocabu_rex_mobile/feed/ui/utils/feed_tokens.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class PostReactionButton extends StatelessWidget {
  final bool hasReacted;
  final bool isOwnPost;
  final ReactionType userReactionType;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final GlobalKey buttonKey;

  const PostReactionButton({
    Key? key,
    required this.hasReacted,
    required this.isOwnPost,
    required this.userReactionType,
    this.onTap,
    this.onLongPress,
    required this.buttonKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: buttonKey,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: FeedTokens.reactionButtonWidth,
        padding: EdgeInsets.symmetric(vertical: FeedTokens.reactionButtonPadding),
        decoration: BoxDecoration(
          color: hasReacted ? AppColors.macawLight : AppColors.snow,
          borderRadius: BorderRadius.circular(FeedTokens.radiusL),
          border: Border.all(
            color: hasReacted ? AppColors.macaw : AppColors.feedDivider,
            width: FeedTokens.borderThick,
          ),
          boxShadow: hasReacted
              ? []
              : [
                  BoxShadow(
                    color: AppColors.swan,
                    offset: const Offset(0, 2),
                    blurRadius: 0,
                  )
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              hasReacted ? userReactionType.emoji : ReactionType.congrats.emoji,
              style: TextStyle(fontSize: FeedTokens.iconM),
            ),
            SizedBox(width: FeedTokens.spacingM),
            Text(
              isOwnPost
                  ? 'CHIA SẺ'
                  : hasReacted
                      ? userReactionType.reactedText
                      : userReactionType.actionText,
              style: TextStyle(
                fontSize: FeedTokens.fontS,
                fontWeight: FeedTokens.fontWeightExtraBold,
                color: isOwnPost
                    ? AppColors.feedTextPrimary
                    : hasReacted
                        ? AppColors.macaw
                        : AppColors.macaw,
                letterSpacing: FeedTokens.letterSpacingNormal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
