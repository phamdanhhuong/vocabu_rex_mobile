import 'package:flutter/material.dart';
import 'colors.dart';

/// App typography inspired by Duolingo: friendly, rounded, legible.
///
/// Notes from Duolingo guidelines:
/// - Feather Bold is a bespoke headline typeface used for large, brief headlines.
/// - Use Feather Bold for display / headline styles, never smaller than 30px on-screen.
/// - Set leading between 100–110% and tracking = -20 (we map tracking to letterSpacing in em units)  .
/// - Body copy should use a neutral, highly readable UI font (e.g., Inter or DIN Next Rounded).
class AppTypography {
  // Primary UI font (for body copy). Add this to pubspec.yaml if you want a custom font.
  /// DIN Next Rounded is the recommended typeface for longer sections of text,
  /// sub-headings and body copy. If you include the font, set the family name
  /// in pubspec.yaml to 'DINNextRounded'.
  static const String uiFont = 'DINNextRounded';
  // Fallback UI font if DIN Next Rounded is not available.
  // Nunito is the recommended substitute font (free on Google Fonts) and
  // visually matches DIN Next Rounded's rounded caps and friendly tone.
  static const String uiFallbackFont = 'Nunito';

  // Feather Bold is a bespoke headline font. If you have the font file, add to pubspec.yaml and
  // use the family name 'FeatherBold' below. If not available, the system will fall back.
  static const String featherBold = 'FeatherBold';

  // Mapping helper: Duolingo tracking values (e.g., -20) are in thousandths of an em.
  // Flutter's letterSpacing is in logical pixels. We convert: letterSpacing = (tracking / 1000) * fontSize
  static double _trackingToLetterSpacing(double tracking, double fontSize) {
    return (tracking / 1000.0) * fontSize;
  }

  /// Build a TextTheme that applies Feather Bold for large/display headlines and `uiFont` for body.
  static TextTheme defaultTextTheme([Color? color]) {
    final baseColor = color ?? AppColors.bodyText;

    // Headline/display sizes (keep >= 30px for Feather Bold as guidance)
    const double displayLargeSize = 40;
    const double displayMediumSize = 34;
    const double displaySmallSize = 28;

    return TextTheme(
      // Display / large headline styles — use Feather Bold
      displayLarge: TextStyle(
        fontFamily: featherBold,
        fontSize: displayLargeSize,
        fontWeight: FontWeight.w800,
        height: 1.05, // 105% leading recommended
        letterSpacing: _trackingToLetterSpacing(-20, displayLargeSize),
        color: baseColor,
      ),
      displayMedium: TextStyle(
        fontFamily: featherBold,
        fontSize: displayMediumSize,
        fontWeight: FontWeight.w800,
        height: 1.06,
        letterSpacing: _trackingToLetterSpacing(-20, displayMediumSize),
        color: baseColor,
      ),
      displaySmall: TextStyle(
        fontFamily: featherBold,
        fontSize: displaySmallSize,
        fontWeight: FontWeight.w800,
        height: 1.07,
        letterSpacing: _trackingToLetterSpacing(-20, displaySmallSize),
        color: baseColor,
      ),

      // Headlines (smaller than display) — use Feather Bold for emphasis but keep sizes sensible
      headlineLarge: TextStyle(
        fontFamily: featherBold,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.08,
        letterSpacing: _trackingToLetterSpacing(-10, 22),
        color: baseColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: featherBold,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.08,
        letterSpacing: _trackingToLetterSpacing(-8, 20),
        color: baseColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: featherBold,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: _trackingToLetterSpacing(-6, 18),
        color: baseColor,
      ),

      // Titles and body use DIN Next Rounded for longer/readable text.
      // Duolingo guidance: set leading to ~140% and tracking to 0 for DIN Next Rounded.
      // Never use body text below 14px on-screen or 14pt in print.
      titleLarge: TextStyle(
        fontFamily: uiFont,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.4,
        color: baseColor,
      ),
      titleMedium: TextStyle(
        fontFamily: uiFont,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: baseColor,
      ),
      titleSmall: TextStyle(
        fontFamily: uiFont,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: baseColor,
      ),

      bodyLarge: TextStyle(
        fontFamily: uiFont,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: baseColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: uiFont,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: baseColor,
      ),
      // Ensure bodySmall does not go below 14px per guidelines
      bodySmall: TextStyle(
        fontFamily: uiFont,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: baseColor,
      ),

      labelLarge: TextStyle(
        fontFamily: uiFont,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: baseColor,
      ),
      labelSmall: TextStyle(
        fontFamily: uiFont,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: baseColor,
      ),
    );
  }

  /// Helper to choose a headline style: if the headline text is long (>10 words)
  /// use the UI font (DIN Next Rounded); otherwise use Feather Bold.
  static TextStyle headlineForWordCount(int wordCount, {double fontSize = 22}) {
    if (wordCount > 10) {
      return TextStyle(
        fontFamily: uiFont,
        fontSize: fontSize,
        height: 1.4,
        color: AppColors.bodyText,
      );
    }
    return TextStyle(
      fontFamily: featherBold,
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      height: 1.06,
      letterSpacing: _trackingToLetterSpacing(-20, fontSize),
      color: AppColors.bodyText,
    );
  }

  // --------------------
  // Combining typefaces guidance
  // --------------------
  /// Duolingo guidance when combining Feather Bold and DIN Next Rounded:
  /// - Feather Bold should be lowercase when used alongside DIN.
  /// - Always left-align when pairing.
  /// - Feather Bold should be ~150% the size of DIN Next Rounded (Feather = 1.5x DIN).
  /// - Use equal leading across the block when possible.
  /// - Avoid using them in the same sentence.
  ///
  /// Helper to compute Feather size given a DIN size (Feather = 1.5x DIN)
  static double featherSizeFromDin(double dinSize) => dinSize * 1.5;

  /// Helper to produce paired TextStyles for headline (Feather) and subhead/body (DIN)
  /// ensuring Feather is larger and both share the same leading (line height).
  static Map<String, TextStyle> pairedFeatherAndDinStyles({
    required double dinSize,
    Color? color,
  }) {
    final c = color ?? AppColors.bodyText;
    final dinStyle = TextStyle(fontFamily: uiFont, fontSize: dinSize, height: 1.4, color: c);
    final featherStyle = TextStyle(
      fontFamily: featherBold,
      fontSize: featherSizeFromDin(dinSize),
      fontWeight: FontWeight.w800,
      height: dinStyle.height,
      letterSpacing: _trackingToLetterSpacing(-20, featherSizeFromDin(dinSize)),
      color: c,
    );

    return {'feather': featherStyle, 'din': dinStyle};
  }

  /// Note: there's no programmatic enforcement of "lowercase" here — ensure text input
  /// is transformed to lowercase at the call site when applying Feather styles alongside DIN.
  
  // --------------------
  // Typesetting specific guidance for the word "Duolingo"
  // --------------------
  /// When using Feather Bold, "Duolingo" should be set in lowercase.
  /// Typing a tilde (~) in Feather Bold will trigger a replacement character of our
  /// entire logotype in design tools — use this pattern where the tilde acts as a
  /// placeholder for the logo. In code you can replace '~' with an Icon or Image widget.
  ///
  /// When using DIN Next Rounded, "Duolingo" should be sentence case.
  static String typesetDuolingo({required bool useFeatherBold, required String sourceText}) {
    // If the source contains a tilde and Feather is used, signal to the caller to
    // replace the tilde with the logo renderable (we return a marker string here).
    if (useFeatherBold) {
      if (sourceText.contains('~')) {
        // return a marker the UI code can detect and replace with an Image/Icon widget
        return sourceText.replaceAll('~', '<DUO_LOGO>');
      }
      // Feather Bold -> lowercase
      return sourceText.replaceAll('Duolingo', 'duolingo').toLowerCase();
    } else {
      // DIN Next Rounded -> sentence case for 'Duolingo'
      // Simple implementation: replace exact 'duolingo' or 'Duolingo' with 'Duolingo'
      return sourceText.replaceAll(RegExp(r'(?i)duolingo'), 'Duolingo');
    }
  }

  // --------------------
  // Please don't (rules & lightweight validators)
  // --------------------
  /// High-level rules the design system enforces:
  /// - Don't combine DIN Next Rounded and Feather Bold in the same sentence.
  /// - Don't use Feather Bold in multiple secondary colors at once.
  /// - Don't set Feather Bold in a neutral color like Eel unless printing in one-color.
  /// - Don't let type run off the display area (always wrap/ellipsize where needed).
  /// - Don't set Feather Bold in Sentence case or Title Case (use lowercase when paired with DIN).
  /// - Don't set a DIN Rounded headline at the same size as the logo.
  ///
  /// NOTE: some rules cannot be robustly enforced automatically (for example detecting
  /// visual overflow or the absence of a logo in layout). The helpers below provide
  /// lightweight checks that rely on simple annotations or numeric inputs and are
  /// intended to be used in linting scripts, storybook checks, or design-time validators.

  /// Check if annotated text contains both Feather and DIN marked segments within a single sentence.
  /// Annotation convention: wrap segments with <FEATHER>...</FEATHER> and <DIN>...</DIN>.
  /// Returns true when a violation is detected.
  static bool containsMixedFontsInSentence(String annotatedText) {
    final sentenceReg = RegExp(r'[^.!?]+[.!?]?');
    final matches = sentenceReg.allMatches(annotatedText);
    for (final m in matches) {
      final s = m.group(0) ?? '';
      if (s.contains('<FEATHER>') && s.contains('<DIN>')) return true;
    }
    return false;
  }

  /// Check whether Feather Bold is being used with more than one secondary color.
  /// Provide the list of colors used for the Feather-styled elements; returns true when
  /// more than one distinct secondary color appears (a violation).
  static bool featherUsedWithMultipleSecondaryColors(List<Color> usedColors) {
    final used = usedColors.where((c) => AppColors.secondaryColors.contains(c)).toSet();
    return used.length > 1;
  }

  /// Check if a given color is a neutral color (e.g., Eel/Wolf/Hare...).
  /// If true and used with Feather Bold in UI, that is a discouraged pattern unless
  /// producing a one-color print design.
  static bool isNeutralColor(Color c) => AppColors.neutralShades.contains(c);

  /// Check whether a DIN headline size is equal to or larger than the logotype x-height
  /// which would violate the rule "don't set a DIN Rounded headline at the same size as the logo".
  /// Returns true when the DIN size is >= logoXHeight.
  static bool dinHeadlineMatchesOrExceedsLogo(double dinSize, double logoXHeight) => dinSize >= logoXHeight;


  // --------------------
  // Hierarchy guidance helpers
  // --------------------
  /// Guidance: When pairing DIN Next Rounded with the logotype,
  /// - ideal headline scale is 1.5x the x-height of the logotype
  /// - maximum allowed scale is 2.0x the x-height
  ///
  /// This helper computes recommended headline font sizes given the logotype x-height
  /// (in logical pixels). Returns a map with 'ideal' and 'maximum' sizes.
  static Map<String, double> headlineSizeFromLogoXHeight(double logoXHeight) {
    final ideal = logoXHeight * 1.5;
    final maximum = logoXHeight * 2.0;
    return {'ideal': ideal, 'maximum': maximum};
  }

  /// Recommend fontWeight when pairing with the logotype: use a light weight for DIN
  /// (e.g., FontWeight.w300 - w400) to ensure contrast with the logotype.
  static FontWeight recommendedDinWeightForLogoPairing() => FontWeight.w300;
}
