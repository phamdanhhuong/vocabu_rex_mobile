import 'package:flutter/material.dart';

class DotLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;
  
  const DotLoadingIndicator({
    super.key,
    this.color = Colors.grey,
    this.size = 12.0,
  });

  @override
  State<DotLoadingIndicator> createState() => _DotLoadingIndicatorState();
}

class _DotLoadingIndicatorState extends State<DotLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Mỗi dot có delay khác nhau
            final delay = index * 0.2;
            final value = (_controller.value - delay) % 1.0;
            
            // Scale từ 1.0 -> 1.5 -> 1.0
            double scale = 1.0;
            if (value < 0.5) {
              scale = 1.0 + (value * 2 * 0.5); // 1.0 -> 1.5
            } else {
              scale = 1.5 - ((value - 0.5) * 2 * 0.5); // 1.5 -> 1.0
            }
            
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.size * 0.3),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
