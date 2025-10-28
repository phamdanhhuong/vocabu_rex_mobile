import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'streak_tokens.dart';

class StreakCard extends StatelessWidget {
  final String title;
  final Widget child;
  const StreakCard({Key? key, required this.title, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(kStreakHorizontalGutter, kStreakOuterSpacing, kStreakHorizontalGutter, 0),
      padding: const EdgeInsets.all(kStreakInnerPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.bodyText,
              fontSize: kCardTitleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: AppColors.snow,
              borderRadius: BorderRadius.circular(kCardBorderRadius),
              border: Border.all(color: AppColors.swan, width: kCardBorderWidth),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
