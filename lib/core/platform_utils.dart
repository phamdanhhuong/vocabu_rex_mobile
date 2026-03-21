import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';

/// Centralized platform detection and responsive breakpoints.
class PlatformUtils {
  PlatformUtils._();

  // ── Breakpoints ──────────────────────────────────────────
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;

  // ── Platform checks ──────────────────────────────────────
  static bool get isWeb => kIsWeb;

  // ── Responsive helpers (require BuildContext) ────────────
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static bool isMobile(BuildContext context) =>
      screenWidth(context) < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final w = screenWidth(context);
    return w >= mobileBreakpoint && w < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      screenWidth(context) >= tabletBreakpoint;

  /// True when a sidebar-style navigation should be used instead of bottom nav.
  static bool useSideNavigation(BuildContext context) =>
      isWeb && !isMobile(context);

  // ── Content max-width constraints ────────────────────────
  /// Max width for form-like pages (login, register…)
  static const double maxFormWidth = 480;

  /// Max width for general content pages
  static const double maxContentWidth = 600;

  /// Max width for feed / list pages
  static const double maxFeedWidth = 800;
}
