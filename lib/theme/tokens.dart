/// Design tokens (sizes, durations, alphas) used across the app.
/// Purpose: avoid magic numbers in widgets and make small tuning easier.
class AppTokens {
  // Header
  static const double headerHeight = 110.0;
  static const double headerButtonWidth = 56.0;

  // Press animation
  static const double pressTranslation = 3.0;
  static const Duration pressAnimationDuration = Duration(milliseconds: 90);

  // Borders
  static const double dividerWidth = 1.0;
  // Alpha values are specified as 0..255 ints but we store them as ints for clarity
  static const int dividerAlpha = 71; // ~0.28 * 255
  static const int titleAlpha = 180;

  // Typography sizes (fallbacks; AppTypography already defines many sizes)
  static const double titleFontSize = 16.0;
  static const double subtitleFontSize = 20.0;

  // Icon sizes
  static const double headerIconSize = 20.0;

  // Learning map / nodes
  static const double nodeWaveAmplitude = 0.48;
  static const double nodeVerticalPadding = 20.0;
  static const double nodeHorizontalPadding = 16.0;
  // Alpha used for muted overlay shadows (0..255)
  static const int overlayShadowAlpha = 200;
  // When blending two colors (e.g. snow and a section shadow) use this
  // factor (0.0..1.0). 0.0 => snow, 1.0 => full shadowColor.
  static const double overlayShadowBlend = 0.5;
}
