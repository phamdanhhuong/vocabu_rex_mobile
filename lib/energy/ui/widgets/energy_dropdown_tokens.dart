class EnergyDropdownTokens {
  // Spacing & padding
  static const double horizontalPadding = 16.0;
  static const double verticalPadding = 24.0;
  static const double sectionSpacing = 24.0;
  static const double itemSpacing = 16.0;

  // Sizes
  static const double titleFontSize = 24.0;
  static const double bodyFontSize = 16.0;
  static const double heartIconSize = 32.0;
  // Increase icon sizes for better legibility in the dropdown buttons
  static const double optionIconSize = 40.0;
  static const double gemPriceIconSize = 30.0;

  // Buttons
  static const double buttonBorderRadius = 16.0;
  static const double buttonBorderWidth = 2.0;
  // Provide sufficient horizontal padding so icon+text+trailing have room.
  // Reduce vertical padding so the content fits inside AppButton's fixed height.
  static const double buttonVerticalPadding = 10.0;
  static const double buttonHorizontalPadding = 20.0;

  // Layout inside buttons
  static const double buttonContentSpacing = 20.0;

  // Overlay / positioning
  static const double overlayHorizontalMargin = 16.0; // left/right
  static const double overlayVerticalOffset = 8.0; // gap below anchor

  // Animation
  static const int openAnimationMs = 260;
  static const int closeAnimationMs = 220;
  static const double slideBeginOffsetY = -0.12;

  // Misc
  static const int defaultGemCostPerEnergy = 10;
  static const int defaultCoinCostPerEnergy = 50;
  static const int defaultMaxHearts = 5;
}
