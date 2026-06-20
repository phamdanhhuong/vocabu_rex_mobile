import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class RandomShimmerBadge extends StatefulWidget {
  final Widget child;

  const RandomShimmerBadge({super.key, required this.child});

  @override
  State<RandomShimmerBadge> createState() => _RandomShimmerBadgeState();
}

class _RandomShimmerBadgeState extends State<RandomShimmerBadge> {
  bool _isShimmering = false;
  Timer? _timer;
  int _shimmerKey = 0;

  @override
  void initState() {
    super.initState();
    _scheduleNextShimmer();
  }

  void _scheduleNextShimmer() {
    // Randomize delay between 3 to 10 seconds
    final waitTime = 3000 + Random().nextInt(7000);
    _timer = Timer(Duration(milliseconds: waitTime), () {
      if (mounted) {
        setState(() {
          _isShimmering = true;
          _shimmerKey++; // Change key to restart shimmer animation
        });
        
        // Shimmer animation duration is around 1.5 seconds.
        // Wait a bit longer to let it finish before turning it off.
        Timer(const Duration(milliseconds: 2000), () {
          if (mounted) {
            setState(() => _isShimmering = false);
            _scheduleNextShimmer();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isShimmering) return widget.child;

    return Stack(
      alignment: Alignment.center,
      children: [
        widget.child,
        Shimmer.fromColors(
          key: ValueKey(_shimmerKey),
          baseColor: Colors.transparent,
          highlightColor: Colors.white.withValues(alpha: 0.7),
          period: const Duration(milliseconds: 1500),
          loop: 1, // Loop once then stop
          child: widget.child,
        ),
      ],
    );
  }
}
