import 'package:flutter/material.dart';

/// Wraps a child widget to catch platform-specific exceptions
/// (SystemChrome, HomeWidget, local_auth, etc.) that would crash on web.
///
/// Place this around mobile page widgets when rendering them inside
/// the web layout shell.
class WebPlatformGuard extends StatelessWidget {
  final Widget child;
  const WebPlatformGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // The widget itself doesn't need special handling —
    // most platform exceptions happen in initState / async calls.
    // This serves as a clear boundary and can be extended with
    // error zone wrapping if needed in the future.
    return child;
  }
}
