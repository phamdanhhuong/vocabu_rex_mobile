import 'package:flutter/material.dart';
import '../../typography.dart';

/// Semantic text widget that centralizes typography usage across the app.
///
/// Use `AppText` with a semantic `AppTextStyle` to ensure consistent type tokens
/// (sizes, weights, tracking) across screens.
class AppText extends StatelessWidget {
  final String data;
  final AppTextStyle style;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppText(
    this.data, {
    Key? key,
    this.style = AppTextStyle.bodyMedium,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  TextStyle _resolveTextStyle(BuildContext context) {
    final textTheme = AppTypography.defaultTextTheme(color);

    switch (style) {
      case AppTextStyle.displayLarge:
        return textTheme.displayLarge!;
      case AppTextStyle.displayMedium:
        return textTheme.displayMedium!;
      case AppTextStyle.displaySmall:
        return textTheme.displaySmall!;
      case AppTextStyle.headlineLarge:
        return textTheme.headlineLarge!;
      case AppTextStyle.headlineMedium:
        return textTheme.headlineMedium!;
      case AppTextStyle.headlineSmall:
        return textTheme.headlineSmall!;
      case AppTextStyle.titleLarge:
        return textTheme.titleLarge!;
      case AppTextStyle.titleMedium:
        return textTheme.titleMedium!;
      case AppTextStyle.titleSmall:
        return textTheme.titleSmall!;
      case AppTextStyle.bodyLarge:
        return textTheme.bodyLarge!;
      case AppTextStyle.bodyMedium:
        return textTheme.bodyMedium!;
      case AppTextStyle.bodySmall:
        return textTheme.bodySmall!;
      case AppTextStyle.labelLarge:
        return textTheme.labelLarge!;
      case AppTextStyle.labelSmall:
        return textTheme.labelSmall!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolved = _resolveTextStyle(context).copyWith(
      color: color ?? AppTypography.defaultTextTheme().bodyMedium!.color,
    );

    return Text(
      data,
      style: resolved,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Semantic names that map to the `TextTheme` properties in `AppTypography`.
enum AppTextStyle {
  displayLarge,
  displayMedium,
  displaySmall,
  headlineLarge,
  headlineMedium,
  headlineSmall,
  titleLarge,
  titleMedium,
  titleSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelSmall,
}
