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
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive font size based on screen width
    final double fontSize = screenWidth < 360 
        ? NodeTokens.topOverlayFontSize * 0.9
        : NodeTokens.topOverlayFontSize;
    
    // Responsive height
    final double height = screenWidth < 360
        ? NodeTokens.topOverlayHeight * 0.9
        : NodeTokens.topOverlayHeight;
    
    // Responsive horizontal padding
    final double horizontalPadding = screenWidth < 360
        ? NodeTokens.topOverlayHorizontalPadding * 0.8
        : NodeTokens.topOverlayHorizontalPadding;

    final textStyle = AppTypography.defaultTextTheme().labelLarge?.copyWith(
      color: sectionColor ?? AppColors.primary,
      fontWeight: FontWeight.w600,
      fontSize: fontSize,
    );

    return IntrinsicWidth(
      child: SpeechBubble(
        variant: SpeechBubbleVariant.neutral,
        tailDirection: SpeechBubbleTailDirection.bottom,
        backgroundColor: AppColors.background,
        borderColor: sectionColor ?? AppColors.primary,
        shadowColor: sectionShadowColor,
        showShadow: sectionShadowColor != null,
        tailOffset: tailOffset,
        child: Container(
          height: height,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
          ),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              text,
              style: textStyle,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
      ),
    );
  }
}
