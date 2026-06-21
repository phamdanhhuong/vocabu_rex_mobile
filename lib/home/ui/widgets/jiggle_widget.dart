import 'dart:math' as math;
import 'package:flutter/material.dart';

class JiggleWidget extends StatefulWidget {
  final Widget child;
  final GlobalKey<JiggleWidgetState>? key;

  const JiggleWidget({this.key, required this.child}) : super(key: key);

  @override
  State<JiggleWidget> createState() => JiggleWidgetState();
}

class JiggleWidgetState extends State<JiggleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  void jiggle() {
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Sine wave for jiggling left and right
        final offset = math.sin(_controller.value * math.pi * 3) * 5.0;
        final scale = 1.0 + math.sin(_controller.value * math.pi) * 0.2;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: Transform.scale(
            scale: scale,
            child: widget.child,
          ),
        );
      },
    );
  }
}
