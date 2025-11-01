import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'node_tokens.dart';

/// Painter that draws two ovals (background + moving top oval) and a centered icon.
class EllipsePainter extends CustomPainter {
  final double offset; // normalized 0..1
  final bool isReached;
  final IconData icon;
  final double iconSize;
  // Optional override so caller can provide a section-specific color palette
  final Color? primaryColorOverride;
  final Color? secondaryColorOverride;

  EllipsePainter({
    required this.offset,
    required this.isReached,
    required this.icon,
    required this.iconSize,
    this.primaryColorOverride,
    this.secondaryColorOverride,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Colors
  final Color primaryColor = isReached
    ? (primaryColorOverride ?? AppColors.primary)
    : AppColors.swan;
  final Color secondaryColor = isReached
    ? (secondaryColorOverride ?? AppColors.wingOverlay)
    : AppColors.hare;

    // Determine oval sizes based on tokens
    final double ovalHeight = size.height * NodeTokens.ovalHeightFactor;
    final double smallGap = ovalHeight * NodeTokens.smallGapRatio;

    // Compute base positions so the pair (upper + gap + lower) is centered vertically
    final double combined = ovalHeight + smallGap;
    final double baseTop = (size.height - combined) / 2.0;

    // rect1 (lower) is fixed at baseTop + smallGap
    final double rect1Top = baseTop + smallGap;
    final Rect rect1 = Rect.fromLTWH(0, rect1Top, size.width, ovalHeight);

    // rect2 (upper) is at baseTop plus an animated shift (offset factor 0..1)
    final double shift = (offset.clamp(0.0, 1.0)) * smallGap;
    final double rect2Top = baseTop + shift;
    final Rect rect2 = Rect.fromLTWH(0, rect2Top, size.width, ovalHeight);

    // Draw lower/background oval first
    final paint = Paint()..color = secondaryColor;
    canvas.drawOval(rect1, paint);

    // Draw upper/top oval
    paint.color = primaryColor;
    canvas.drawOval(rect2, paint);

    // Draw icon centered on the upper oval
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: iconSize,
          fontWeight: FontWeight.bold,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: isReached ? NodeTokens.iconColorReached : NodeTokens.iconColorUnreached,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final centerX = rect2.left + rect2.width / 2;
    final centerY = rect2.top + rect2.height / 2;

    canvas.save();
    canvas.translate(centerX, centerY);
    final scaleX = rect2.width / rect2.height;
    canvas.scale(scaleX, 1.0);
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant EllipsePainter oldDelegate) {
    return oldDelegate.offset != offset || oldDelegate.isReached != isReached || oldDelegate.icon != icon;
  }
}
