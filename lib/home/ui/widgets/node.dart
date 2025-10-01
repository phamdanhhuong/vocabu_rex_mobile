import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_level_entity.dart';

class Node extends StatefulWidget {
  final SkillLevelEntity skillLevel;
  const Node({super.key, required this.skillLevel});

  @override
  State<Node> createState() => _NodeState();
}

class _NodeState extends State<Node> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offsetAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 70),
    );

    _offsetAnim = Tween<double>(
      begin: 0,
      end: 8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward(); // nhấn xuống thì animate xuống
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse(); // nhả ra thì animate về vị trí ban đầu
  }

  void _onTapCancel() {
    _controller.reverse(); // nếu kéo ra ngoài thì cũng về lại
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _offsetAnim, // đảm bảo _offsetAnim luôn có giá trị
        builder: (context, child) {
          return CustomPaint(
            size: const Size(70, 50),
            painter: EllipsePainter(offset: _offsetAnim.value),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class EllipsePainter extends CustomPainter {
  final double offset;

  EllipsePainter({required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color.fromARGB(255, 41, 119, 44);

    // oval nền
    Rect rect = Rect.fromLTWH(0, 10, size.width, size.height);
    canvas.drawOval(rect, paint);

    // oval có animation dịch xuống
    paint.color = Colors.green;
    Rect rect2 = Rect.fromLTWH(0, offset, size.width, size.height);
    canvas.drawOval(rect2, paint);
  }

  @override
  bool shouldRepaint(covariant EllipsePainter oldDelegate) {
    return oldDelegate.offset != offset;
  }
}
