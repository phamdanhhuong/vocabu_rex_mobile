import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'progress_ring_painter.dart';

class NodeVisual extends StatelessWidget {
  final double ringSize;
  final double ringStrokeWidth;
  final double progress;
  final Color progressColor;
  final Widget nodeChild;

  const NodeVisual({
    Key? key,
    required this.ringSize,
    required this.ringStrokeWidth,
    required this.progress,
    required this.progressColor,
    required this.nodeChild,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ringSize,
      height: ringSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(ringSize, ringSize),
            painter: ProgressRingPainter(
              progress: progress,
              backgroundColor: AppColors.swan,
              progressColor: progressColor,
              strokeWidth: ringStrokeWidth,
            ),
          ),
          // center node inside ring
          nodeChild,
        ],
      ),
    );
  }
}
