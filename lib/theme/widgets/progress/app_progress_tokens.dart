/// Design tokens for progress components (avoid magic numbers in widgets)
class AppProgressTokens {
  // Default dimensions
  static const double defaultWidth = 235.55;
  static const double defaultHeight = 16.0;
  static const double borderRadius = 8.0;

  // Highlight relative sizes (as fraction of width/height)
  static const double highlightWidthFraction = 0.13; // ~31px on default width
  static const double highlightHeightFraction = 0.30; // ~4.8px on default height
  static const double highlightLeftFraction = 0.034; // ~8px on default width

  // Label sizing (fraction of width)
  static const double labelWidthFraction = 0.35;

  // Animation timings
  static const Duration progressAnimation = Duration(milliseconds: 300);
  static const Duration streakMessageDuration = Duration(milliseconds: 2500);

  // Label translation (relative offsets)
  static const double labelTranslateXFraction = 0.075; // shift left relative to width
  static const double labelTranslateYMultiplier = 1.5; // multiply by height for vertical offset

  // Streak / message sizes
  static const double streakFontSize = 16.0;
  static const double streakIconSize = 20.0;
}
