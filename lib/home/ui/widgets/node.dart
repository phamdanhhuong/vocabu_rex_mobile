import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_level_entity.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';

class Node extends StatefulWidget {
  final SkillLevelEntity skillLevel;
  final bool isReached;
  final bool isCurrent;
  final int lessonPosition;

  const Node({
    super.key,
    required this.skillLevel,
    required this.isReached,
    required this.isCurrent,
    required this.lessonPosition,
  });

  @override
  State<Node> createState() => _NodeState();
}

class _NodeState extends State<Node> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offsetAnim;
  SkillLevelEntity get _skillLevel => widget.skillLevel;
  bool get _isReached => widget.isReached;
  bool get _isCurrent => widget.isCurrent;
  int get _lessonPosition => widget.lessonPosition;

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

  OverlayEntry? _overlayEntry;

  void _showOverlay(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Lớp trong suốt phủ toàn màn hình để bắt sự kiện chạm ra ngoài
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _removeOverlay();
              },
              child: Container(color: AppColors.transparent),
            ),
          ), // Popup
          Positioned(
            left: offset.dx - 70,
            top: offset.dy + 65, // popup nằm trên node
            child: Material(
              color: AppColors.transparent,
              child: Container(
                width: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isReached
                      ? AppColors.nodeReachedPrimary
                      : AppColors.nodeUnreachedBorder,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isReached
                        ? AppColors.transparent
                        : AppColors.borderGrey,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      color: AppColors.overlayBlack26,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _skillLevel.description,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    _isCurrent
                        ? Text(
                            _skillLevel.lessons != null
                                ? "Bài học  ${_lessonPosition}/${_skillLevel.lessons!.length}"
                                : "Bài học: 0",
                            style: TextStyle(color: AppColors.textWhite70),
                          )
                        : _isReached
                        ? const Text(
                            "Ôn tập bài học",
                            style: TextStyle(color: AppColors.textWhite70),
                            textAlign: TextAlign.center,
                          )
                        : const Text(
                            "Hãy hoàn thành các bài học trước để mở khóa",
                            style: TextStyle(color: AppColors.textWhite70),
                            textAlign: TextAlign.center,
                          ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textWhite,
                        foregroundColor: _isReached
                            ? AppColors.nodeReachedPrimary
                            : AppColors.nodeUnreachedBorder,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        _removeOverlay();
                        if (_isCurrent) {
                          Navigator.pushNamed(
                            context,
                            '/exercise',
                            arguments: {
                              'lessonId':
                                  _skillLevel.lessons?[_lessonPosition - 1].id,
                              'lessonTitle': _skillLevel
                                  .lessons?[_lessonPosition - 1]
                                  .title,
                            },
                          );
                        }
                      },
                      child: _isReached ? Text("BẮT ĐẦU") : Text("Khóa"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Animate xuống
        _controller.forward();

        // Đợi animation hoàn thành
        await Future.delayed(const Duration(milliseconds: 100));

        // Animate về vị trí ban đầu
        _controller.reverse();

        // Xử lý hiển thị overlay
        if (_overlayEntry == null) {
          _showOverlay(context);
        } else {
          _removeOverlay();
        }
      },
      child: AnimatedBuilder(
        animation: _offsetAnim, // đảm bảo _offsetAnim luôn có giá trị
        builder: (context, child) {
          return CustomPaint(
            size: const Size(70, 50),
            painter: EllipsePainter(
              offset: _offsetAnim.value,
              isReached: _isReached,
            ),
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
  final bool isReached;

  EllipsePainter({required this.offset, required this.isReached});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isReached
          ? AppColors.nodeReachedSecondary
          : AppColors.nodeUnreachedSecondary;

    // oval nền
    Rect rect = Rect.fromLTWH(0, 10, size.width, size.height);
    canvas.drawOval(rect, paint);

    // oval có animation dịch xuống
    paint.color = isReached
        ? AppColors.nodeReachedPrimary
        : AppColors.nodeUnreachedPrimary;
    Rect rect2 = Rect.fromLTWH(0, offset, size.width, size.height);
    canvas.drawOval(rect2, paint);
  }

  @override
  bool shouldRepaint(covariant EllipsePainter oldDelegate) {
    return oldDelegate.offset != offset;
  }
}
