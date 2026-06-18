import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/feed/domain/enums/feed_enums.dart';
import 'dart:math' as math;

class ConfettiParticle {
  final double x;
  final double y;
  final double angle;
  final double speed;
  final Color color;
  final double size;
  final String emoji;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.angle,
    required this.speed,
    required this.color,
    required this.size,
    required this.emoji,
  });
}

class ConfettiOverlay extends StatefulWidget {
  final Offset position;
  final ReactionType reactionType;
  final VoidCallback onComplete;

  const ConfettiOverlay({
    super.key,
    required this.position,
    required this.reactionType,
    required this.onComplete,
  });

  static void show(BuildContext context, Offset position, ReactionType type) {
    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (context) => ConfettiOverlay(
        position: position,
        reactionType: type,
        onComplete: () {
          entry?.remove();
        },
      ),
    );
    Overlay.of(context).insert(entry);
  }

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();
  
  List<Color> _getColors(ReactionType type) {
    switch (type) {
      case ReactionType.fire:
        return [Colors.red, Colors.orange, Colors.yellow, Colors.deepOrange];
      case ReactionType.heart:
        return [Colors.pink, Colors.red, Colors.pinkAccent];
      case ReactionType.clap:
        return [Colors.yellow, Colors.amber, Colors.orangeAccent];
      case ReactionType.strong:
        return [Colors.blue, Colors.purple, Colors.deepPurple];
      case ReactionType.congrats:
      default:
        return [
          const Color(0xFFFF5252), const Color(0xFF448AFF),
          const Color(0xFF69F0AE), const Color(0xFFFFD740),
          const Color(0xFFE040FB), const Color(0xFFFFAB40),
        ];
    }
  }

  List<String> _getEmojis(ReactionType type) {
    switch (type) {
      case ReactionType.fire: return ['🔥', '✨'];
      case ReactionType.heart: return ['❤️', '💖', '💘'];
      case ReactionType.clap: return ['👏', '✨', '⭐'];
      case ReactionType.strong: return ['💪', '💥', '⚡'];
      case ReactionType.congrats:
      default: return ['🎉', '✨', '👏', '💖', '🔥', '⭐'];
    }
  }

  @override
  void initState() {
    super.initState();
    final colors = _getColors(widget.reactionType);
    final emojis = _getEmojis(widget.reactionType);

    for (int i = 0; i < 40; i++) {
      // Concentrate particles upwards and outwards
      double angle = -math.pi / 2 + (_random.nextDouble() - 0.5) * math.pi;
      
      _particles.add(ConfettiParticle(
        x: 0,
        y: 0,
        angle: angle,
        speed: 100 + _random.nextDouble() * 250,
        color: colors[_random.nextInt(colors.length)],
        size: 8 + _random.nextDouble() * 12,
        emoji: _random.nextDouble() > 0.6 ? emojis[_random.nextInt(emojis.length)] : '',
      ));
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..addListener(() {
        setState(() {});
      })..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onComplete();
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: _particles.map((p) {
            final progress = _controller.value;
            // Easing out
            final easeOut = 1 - math.pow(1 - progress, 4);
            
            // Calculate physics
            final dx = widget.position.dx + math.cos(p.angle) * p.speed * easeOut;
            // Add gravity (progress squared) to make them fall
            final dy = widget.position.dy + math.sin(p.angle) * p.speed * easeOut + (math.pow(progress, 2) * 300); 
            
            // Fade out near the end
            double opacity = 1.0;
            if (progress > 0.7) {
              opacity = (1.0 - progress) / 0.3;
            }

            return Positioned(
              left: dx - p.size / 2,
              top: dy - p.size / 2,
              child: Transform.rotate(
                angle: progress * 15 * (_particles.indexOf(p) % 2 == 0 ? 1 : -1),
                child: Opacity(
                  opacity: opacity,
                  child: p.emoji.isNotEmpty
                    ? Text(p.emoji, style: TextStyle(fontSize: p.size * 2))
                    : Container(
                        width: p.size,
                        height: p.size,
                        decoration: BoxDecoration(
                          color: p.color,
                          shape: _particles.indexOf(p) % 3 == 0 ? BoxShape.circle : BoxShape.rectangle,
                        ),
                      ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
