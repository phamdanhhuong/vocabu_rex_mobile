import 'dart:math';
import 'package:flutter/material.dart';

class CoinFlyingAnimation extends StatefulWidget {
  final Offset startPosition;
  final Offset endPosition;
  final VoidCallback onComplete;

  const CoinFlyingAnimation({
    Key? key,
    required this.startPosition,
    required this.endPosition,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<CoinFlyingAnimation> createState() => _CoinFlyingAnimationState();
}

class _CoinFlyingAnimationState extends State<CoinFlyingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _xAnimation;
  late Animation<double> _yAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Arc movement using different curves for X and Y
    _xAnimation = Tween<double>(
      begin: widget.startPosition.dx,
      end: widget.endPosition.dx,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine));

    _yAnimation = Tween<double>(
      begin: widget.startPosition.dy,
      end: widget.endPosition.dy,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInCubic));

    _opacityAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 80),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 10),
    ]).animate(_controller);

    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.2), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.8), weight: 80),
    ]).animate(_controller);

    _controller.forward().then((_) {
      widget.onComplete();
    });
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
        return Positioned(
          left: _xAnimation.value,
          top: _yAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Image.asset(
                'assets/icons/coin.png',
                width: 32,
                height: 32,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Helper to show multiple coins flying
void showCoinFlyingOverlay(BuildContext context, Offset start, Offset end, VoidCallback onAllComplete) {
  final overlayState = Overlay.of(context);
  int completedCount = 0;
  const totalCoins = 10;
  final random = Random();

  for (int i = 0; i < totalCoins; i++) {
    // Spread the start positions slightly so they look like an explosion
    final startWithSpread = Offset(
      start.dx + (random.nextDouble() * 80 - 40),
      start.dy + (random.nextDouble() * 80 - 40),
    );

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return CoinFlyingAnimation(
          startPosition: startWithSpread,
          endPosition: end,
          onComplete: () {
            entry.remove();
            completedCount++;
            if (completedCount == totalCoins) {
              onAllComplete();
            }
          },
        );
      },
    );

    // Stagger the animations
    Future.delayed(Duration(milliseconds: i * 60), () {
      overlayState.insert(entry);
    });
  }
}
