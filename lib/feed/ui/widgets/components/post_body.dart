import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/feed/ui/utils/feed_constants.dart';
import 'package:vocabu_rex_mobile/feed/ui/utils/feed_tokens.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class PostBody extends StatelessWidget {
  final String content;
  final PostTypeConfig config;

  const PostBody({
    Key? key,
    required this.content,
    required this.config,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Content Text on the Left
        Expanded(
          child: Text(
            content,
            style: TextStyle(
              fontSize: FeedTokens.fontXxl,
              color: AppColors.feedTextPrimary,
              height: FeedTokens.lineHeightTight,
              fontWeight: FeedTokens.fontWeightRegular,
            ),
          ),
        ),
        SizedBox(width: FeedTokens.spacingL),

        // Large Achievement Icon on the Right
        Container(
          width: FeedTokens.postAchievementIconSize,
          height: FeedTokens.postAchievementIconSize,
          decoration: BoxDecoration(
            color: config.backgroundColor.withOpacity(0.1), 
            shape: BoxShape.circle,
          ),
          child: Icon(
            config.icon,
            size: FeedTokens.iconXxl,
          ),
        ),
      ],
    );
  }
}
