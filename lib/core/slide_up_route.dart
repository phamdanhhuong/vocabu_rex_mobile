import 'package:flutter/material.dart';

/// A small reusable page route that slides the new page up from the bottom
/// and reverses when popped.
class SlideUpPageRoute<T> extends PageRouteBuilder<T> {
  final WidgetBuilder builder;
  SlideUpPageRoute({required this.builder, RouteSettings? settings})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          settings: settings,
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 260),
          opaque: false,
        );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    // Slide from bottom and fade in a scrim behind the page
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(curved),
        child: child,
      ),
    );
  }
}
