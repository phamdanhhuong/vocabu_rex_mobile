import 'package:flutter/widgets.dart';
import 'package:vocabu_rex_mobile/core/platform_utils.dart';

/// A widget that builds different layouts based on screen width.
///
/// Usage:
/// ```dart
/// ResponsiveLayout(
///   mobile: MobileView(),
///   tablet: TabletView(),   // optional – falls back to desktop or mobile
///   desktop: DesktopView(), // optional – falls back to mobile
/// )
/// ```
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= PlatformUtils.tabletBreakpoint) {
          return desktop ?? tablet ?? mobile;
        }
        if (constraints.maxWidth >= PlatformUtils.mobileBreakpoint) {
          return tablet ?? desktop ?? mobile;
        }
        return mobile;
      },
    );
  }
}

/// Wraps content in a centered [ConstrainedBox] so it doesn't stretch
/// edge-to-edge on wide screens. On mobile it has no effect.
///
/// ```dart
/// ResponsiveContentWrapper(
///   maxWidth: PlatformUtils.maxFormWidth,
///   child: LoginForm(),
/// )
/// ```
class ResponsiveContentWrapper extends StatelessWidget {
  final double maxWidth;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContentWrapper({
    super.key,
    this.maxWidth = PlatformUtils.maxContentWidth,
    this.padding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );
  }
}
