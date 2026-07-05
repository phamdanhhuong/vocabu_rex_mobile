import 'package:flutter/material.dart';

/// Hiển thị 3 sao với animation fill dần
class StarDisplayWidget extends StatefulWidget {
  final int stars; // 0-3
  final double size;
  final bool animate;

  const StarDisplayWidget({
    super.key,
    required this.stars,
    this.size = 48,
    this.animate = true,
  });

  @override
  State<StarDisplayWidget> createState() => _StarDisplayWidgetState();
}

class _StarDisplayWidgetState extends State<StarDisplayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _starAnims;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _starAnims = List.generate(3, (i) {
      final start = i * 0.25;
      final end = start + 0.4;
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(start.clamp(0, 1), end.clamp(0, 1),
            curve: Curves.elasticOut),
      );
    });

    if (widget.animate) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _controller.forward();
      });
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
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final filled = i < widget.stars;
        return AnimatedBuilder(
          animation: _starAnims[i],
          builder: (context, child) {
            return Transform.scale(
              scale: filled ? _starAnims[i].value : 1.0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: widget.size * 0.08),
                child: Icon(
                  Icons.star_rounded,
                  size: widget.size,
                  color: filled ? const Color(0xFFFFC107) : const Color(0xFFE0E0E0),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
