import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/typography.dart';
import 'node_tokens.dart';
import 'package:vocabu_rex_mobile/theme/widgets/speech_bubbles/speech_bubble.dart';

/// Small, reusable top badge used above an in-progress node.
class TopOverlay extends StatelessWidget {
  final String text;
  final Color? sectionColor;
  final Color? sectionShadowColor;
  final double tailOffset;

  const TopOverlay({
    Key? key,
    required this.text,
    this.sectionColor,
    this.sectionShadowColor,
    required this.tailOffset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = AppTypography.defaultTextTheme().labelLarge?.copyWith(
      color: sectionColor ?? AppColors.primary,
      fontWeight: FontWeight.w600,
      fontSize: NodeTokens.topOverlayFontSize,
    );

    return SpeechBubble(
      variant: SpeechBubbleVariant.neutral,
      tailDirection: SpeechBubbleTailDirection.bottom,
      backgroundColor: AppColors.snow,
      borderColor: sectionColor ?? AppColors.primary,
      shadowColor: sectionShadowColor,
      showShadow: sectionShadowColor != null,
      tailOffset: tailOffset,
      child: Container(
        height: NodeTokens.topOverlayHeight,
        padding: const EdgeInsets.symmetric(horizontal: NodeTokens.topOverlayHorizontalPadding),
        alignment: Alignment.center,
        child: Text(
          text,
          style: textStyle,
        ),
      ),
    );
  }
}
