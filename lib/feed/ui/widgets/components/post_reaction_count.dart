import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/feed/domain/enums/feed_enums.dart';
import 'package:vocabu_rex_mobile/feed/ui/utils/feed_tokens.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class PostReactionCount extends StatelessWidget {
  final int totalReactions;
  final List<ReactionType> reactionTypes;
  final VoidCallback onTap;

  const PostReactionCount({
    Key? key,
    required this.totalReactions,
    required this.reactionTypes,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (totalReactions == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          // Hiển thị tối đa 3 reaction types chồng lên nhau
          SizedBox(
            width: reactionTypes.isEmpty 
                ? FeedTokens.reactionCircleSize
                : (FeedTokens.reactionCircleSize + (reactionTypes.length > FeedTokens.maxReactionTypesDisplay ? 2 : reactionTypes.length - 1) * FeedTokens.reactionCircleOverlap),
            height: FeedTokens.reactionCircleSize,
            child: Stack(
              children: [
                for (int i = (reactionTypes.length > FeedTokens.maxReactionTypesDisplay ? FeedTokens.maxReactionTypesDisplay : reactionTypes.length) - 1; i >= 0; i--)
                  Positioned(
                    left: i * FeedTokens.reactionCircleOverlap,
                    child: Container(
                      width: FeedTokens.reactionCircleSize,
                      height: FeedTokens.reactionCircleSize,
                      padding: EdgeInsets.all(FeedTokens.reactionCirclePadding),
                      decoration: BoxDecoration(
                        color: AppColors.snow,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.feedDivider, width: FeedTokens.borderThick),
                      ),
                      child: Center(
                        child: Text(
                          reactionTypes[reactionTypes.length > FeedTokens.maxReactionTypesDisplay ? reactionTypes.length - FeedTokens.maxReactionTypesDisplay + i : i].emoji,
                          style: TextStyle(fontSize: FeedTokens.iconS),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(width: FeedTokens.spacingHorizontalM),

          // Số nằm bên ngoài
          Text(
            '$totalReactions',
            style: TextStyle(
              fontSize: FeedTokens.fontS,
              fontWeight: FeedTokens.fontWeightBold,
              color: AppColors.feedTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
