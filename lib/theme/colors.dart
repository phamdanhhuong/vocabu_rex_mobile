import 'package:flutter/material.dart';

/// App color palette inspired by Duolingo design: playful, saturated, high-contrast.

class AppColors {
  // Core brand colors (from Duolingo style guide provided):
  // 1. Feather Green - core brand hue (use as primary/brand color)
  // 2. Mask Green - secondary/placement green for Duo
  // 3. Eel - typography color
  // 4. Snow - primary background color

  /// Feather Green
  /// Hex: #58CC02  — RGB(88,204,2)
  static const Color featherGreen = Color(0xFF58CC02);

  /// Mask Green
  /// Hex: #89E219  — RGB(137,226,25)
  static const Color maskGreen = Color(0xFF89E219);

  /// Eel (used for typography)
  /// Hex: #4B4B4B  — RGB(75,75,75)
  static const Color eel = Color(0xFF4B4B4B);

  /// Snow (background)
  /// Hex: #FFFFFF
  static const Color snow = Color(0xFFFFFFFF);

  // Neutral family (utility and hierarchy)
  /// Wolf
  /// Hex: #777777  — RGB(119,119,119)
  static const Color wolf = Color(0xFF777777);

  /// Hare
  /// Hex: #AFAFAF  — RGB(175,175,175)
  static const Color hare = Color(0xFFAFAFAF);

  /// Swan
  /// Hex: #E5E5E5  — RGB(229,229,229)
  static const Color swan = Color(0xFFE5E5E5);

  /// Polar
  /// Hex: #F7F7F7  — RGB(247,247,247)
  static const Color polar = Color(0xFFF7F7F7);

  // Additional helpful tokens
  static const Color black = Color(0xFF000000);
  static const Color white = snow;

  // Semantic aliases for easier usage across the app
  static const Color primary = featherGreen;
  static const Color primaryVariant = maskGreen;
  static const Color onPrimary = snow;
  static const Color bodyText = eel;
  static const Color background = snow;

  /// Neutral shades from dark to light
  static const List<Color> neutralShades = [eel, wolf, hare, swan, polar, snow];

  // Secondary vibrant palette (used for splashes of delight / illustrations / full-bleed backgrounds)
  /// Macaw
  /// Hex: #1CB0F6  — RGB(28,176,246)
  static const Color macaw = Color(0xFF1CB0F6);

  // --- MÀU MỚI CHO TRẠNG THÁI 'SELECTED' ---
  /// Selection Blue Dark (Dùng cho viền và bóng của WordTile)
  /// Hex: #84D8FF
  static const Color selectionBlueDark = Color(0xFF84D8FF);

  /// Selection Blue Light (Dùng cho nền của WordTile)
  /// Hex: #DDF4FF
  static const Color selectionBlueLight = Color(0xFFDDF4FF);
  // --- KẾT THÚC MÀU MỚI ---

  // --- MÀU MỚI CHO TRẠNG THÁI 'CORRECT' VÀ 'INCORRECT' ---
  /// Correct Green Light (Dùng cho nền WordTile khi đúng)
  /// Hex: #BBF27A
  static const Color correctGreenLight = Color(0xFFBBF27A);

  /// Incorrect Red Light (Dùng cho nền WordTile khi sai)
  /// Hex: #FFDDE5
  static const Color incorrectRedLight = Color(0xFFFFDDE5);

  static const Color correctGreenDark = Color(0xFF89E219);

  /// Incorrect Red Light (Dùng cho nền WordTile khi sai)
  /// Hex: #FFDDE5
  static const Color incorrectRedDark = Color(0xFFffb2b2);
  // --- KẾT THÚC MÀU MỚI ---

  /// Cardinal
  /// Hex: #FF4B4B  — RGB(255,75,75)
  static const Color cardinal = Color(0xFFFF4B4B);

  /// Tomato (custom red)
  /// Hex: #EA2B2B — RGB(234,43,43)
  static const Color tomato = Color(0xFFEA2B2B);

  /// Bee
  /// Hex: #FFC800  — RGB(255,200,0)
  static const Color bee = Color(0xFFFFC800);

  /// Fox
  /// Hex: #FF9600  — RGB(255,150,0)
  static const Color fox = Color(0xFFFF9600);

  /// Beetle
  /// Hex: #CE82FF  — RGB(206,130,255)
  static const Color beetle = Color(0xFFCE82FF);

  /// Humpback
  /// Hex: #2B70C9  — RGB(43,112,201)
  static const Color humpback = Color(0xFF2B70C9);

  /// A convenient list of secondary colors for random/iterative use in illustrations
  static const List<Color> secondaryColors = [
    macaw,
    cardinal,
    bee,
    fox,
    beetle,
    humpback,
  ];

  // Duo (mascot) specific palette — colors for Duo's body parts and overlays
  /// Wing Overlay
  /// Hex: #43C000 — RGB(67,192,0)
  static const Color wingOverlay = Color(0xFF43C000);

  // Feather Green and Mask Green already defined above (featherGreen, maskGreen)

  /// Beak Inner
  /// Hex: #B66E28 — RGB(182,110,40)
  static const Color beakInner = Color(0xFFB66E28);

  /// Beak Lower / Feet
  /// Hex: #F49000 — RGB(244,144,0)
  static const Color beakLower = Color(0xFFF49000);

  /// Beak Upper
  /// Hex: #FFC200 — RGB(255,194,0)
  static const Color beakUpper = Color(0xFFFFC200);

  /// Beak Highlight
  /// Hex: #FFDE00 — RGB(255,222,0)
  static const Color beakHighlight = Color(0xFFFFDE00);

  /// Tongue Pink
  /// Hex: #FFCAFF — RGB(255,202,255)
  static const Color tonguePink = Color(0xFFFFCAFF);

  /// Duo palette convenience list (useful for illustrations and parts coloring)
  static const List<Color> duoPalette = [
    wingOverlay,
    featherGreen,
    maskGreen,
    beakInner,
    beakLower,
    beakUpper,
    beakHighlight,
    tonguePink,
    eel,
    polar,
    snow,
  ];
}
