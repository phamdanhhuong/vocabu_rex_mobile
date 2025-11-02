import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

/// Small tokens for LessonNode sizing, animation and colors to avoid magic numbers.
class NodeTokens {
  // Node base sizing
  static const double baseWidth = 72.0;
  // baseHeight will be derived from baseWidth (square area) by the widget

  // Shadow and ring
  static const double shadowHeight = 6.0;
  static const double ringStrokeWidth = 10.0;
  static const double ringGap = 12.0;

  // Oval layout (proportion of the available height used by each oval)
  static const double ovalHeightFactor = 0.82; // controls how tall each oval is
  static const double smallGapRatio = 1.0 / 8.0; // smallGap = ovalHeight * smallGapRatio

  // Animation
  static const Duration pressDuration = Duration(milliseconds: 70);
  static const double offsetEnd = 1.0; // normalized offset target (0..1)

  // Overlay show/hide animation
  static const Duration overlayAnimationDuration = Duration(milliseconds: 220);
  // Extra spacing to push popup B a bit further from the node so the tail
  // appears slightly extended.
  static const double popupTailSpacing = .0;
  // Horizontal padding used when positioning the full-screen popup overlay
  static const double overlayHorizontalPadding = 80.0;
  // Estimated popup height used for simple placement math
  static const double popupEstimateHeight = 170.0;
  // Tail / triangle size used in SpeechBubble placements
  static const double popupTailSize = 20.0;
  // Small margin used when clamping tail inside popup bounds
  static const double popupTailClampMargin = 12.0;

  // Icon
  static const double iconSize = 24.0;
  static const Color iconColorReached = AppColors.white;
  static const Color iconColorUnreached = AppColors.hare;

  // Top overlay (small badge above the current in-progress node)
  static const double topOverlayHeight = 30.0;
  static const double topOverlayHorizontalPadding = 6.0;
  static const double topOverlayVerticalPadding = 6.0;
  static const double topOverlayBorderRadius = 12.0;
  static const double topOverlayFontSize = 13.0;
  // Top overlay vertical placement multipliers
  static const double topOverlayTopMultiplier = 1.2; // used to offset above node
  static const double topOverlayExtraMultiplier = 0.3; // used to push node down slightly
  // Idle floating animation for top overlay (vertical bob)
  static const double topOverlayFloatDistance = 6.0; // px travel up/down
  static const Duration topOverlayFloatDuration = Duration(milliseconds: 1800);
  // Alpha for subtle shadows used in overlays
  static const int overlayShadowAlpha = 40; // used via withAlpha
}
