/// Design tokens for bottom navigation component (avoid magic numbers in widget)
class AppBottomNavTokens {
  // Dimensions
  static const double height = 60.0;
  static const double topBorderWidth = 1.0;
  static const double paddingHorizontal = 4.0;
  static const double paddingVertical = 4.0;
  static const double aspectRatio = 1.0; // square button

  // Animation
  static const int animationDurationMs = 200;

  // Selected decoration
  static const double selectedBorderRadius = 12.0;
  static const double selectedBorderWidth = 2.0;

  // Behavior
  static const int expectedItemCount = 6; // keep in sync with ContentPage
}
