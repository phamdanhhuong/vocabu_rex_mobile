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

  // Icon
  static const double iconSize = 24.0;
  static const Color iconColorReached = AppColors.white;
  static const Color iconColorUnreached = AppColors.hare;
}
