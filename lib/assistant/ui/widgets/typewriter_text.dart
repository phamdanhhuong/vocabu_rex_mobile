import 'package:flutter/material.dart';

class TypewriterText extends StatefulWidget {
  final String text;
  final Widget Function(BuildContext context, String animatedText) builder;
  final Duration durationPerChar;
  final bool animate;

  const TypewriterText({
    Key? key,
    required this.text,
    required this.builder,
    this.durationPerChar = const Duration(milliseconds: 15),
    this.animate = true,
  }) : super(key: key);

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _lengthAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    final totalDuration = widget.durationPerChar * widget.text.length;
    _controller = AnimationController(
      vsync: this,
      duration: totalDuration > const Duration(milliseconds: 50) 
          ? totalDuration 
          : const Duration(milliseconds: 50),
    );

    _lengthAnimation = IntTween(begin: 0, end: widget.text.length).animate(_controller);

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.animate != widget.animate) {
      _controller.dispose();
      _setupAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return widget.builder(context, widget.text);
    }
    
    return AnimatedBuilder(
      animation: _lengthAnimation,
      builder: (context, child) {
        // Safe substring in case length animation exceeds somehow
        final end = _lengthAnimation.value.clamp(0, widget.text.length);
        final currentText = widget.text.substring(0, end);
        return widget.builder(context, currentText);
      },
    );
  }
}
