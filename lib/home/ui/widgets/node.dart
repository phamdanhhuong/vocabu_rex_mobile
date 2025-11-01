import 'package:flutter/material.dart';
import 'dart:math'; // Cần cho pi
import 'package:vocabu_rex_mobile/home/domain/entities/skill_level_entity.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'node_tokens.dart';
import 'ellipse_painter.dart';
import 'progress_ring_painter.dart';

/// Enum cho các trạng thái trực quan của Node
enum NodeStatus {
  locked,      // Chưa mở khóa (xám)
  inProgress,  // Đang làm (xanh lá, có vòng %
  completed,   // Đã vượt ải (xanh lá, bóng loáng)
  legendary,   // Đạt huyền thoại (vàng, bóng loáng)
}

class LessonNode extends StatefulWidget {
  final SkillLevelEntity skillLevel;
  final int lessonPosition; // Vị trí bài học hiện tại (ví dụ: 1)
  final int totalLessons;   // Tổng số bài học (ví dụ: 4)
  final NodeStatus status;    // Trạng thái mới
  final double shadowShiftFactor; // proportion of shadowH used to shift shadow below main

  const LessonNode({
    super.key,
    required this.skillLevel,
    required this.status,
    this.lessonPosition = 0,
    this.totalLessons = 4, // Giả sử
    this.shadowShiftFactor = 0.6,
  });

  @override
  State<LessonNode> createState() => _LessonNodeState();
}

class _LessonNodeState extends State<LessonNode> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offsetAnim;
  
  // Lấy giá trị từ widget
  SkillLevelEntity get _skillLevel => widget.skillLevel;
  NodeStatus get _status => widget.status;
  double get _progress => (widget.totalLessons > 0) ? widget.lessonPosition / widget.totalLessons : 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: NodeTokens.pressDuration,
    );

    _offsetAnim = Tween<double>(
      begin: 0,
      end: NodeTokens.offsetEnd,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  OverlayEntry? _overlayEntry;

  // --- LOGIC HIỂN THỊ OVERLAY (GIỮ NGUYÊN) ---
  void _showOverlay(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    Color popupBgColor;
    Color popupBorderColor;
    Color buttonTextColor;
    String title;
    String subtitle;
    String buttonText;
    bool isLocked = false;

    switch (_status) {
      case NodeStatus.legendary:
        popupBgColor = AppColors.bee;
        popupBorderColor = Colors.transparent;
        buttonTextColor = AppColors.fox;
        title = _skillLevel.description;
        subtitle = "Bạn đã đạt cấp độ Huyền thoại!";
        buttonText = "ÔN TẬP +5 KN";
        break;
      case NodeStatus.completed:
        popupBgColor = AppColors.correctGreenLight;
        popupBorderColor = Colors.transparent;
        buttonTextColor = AppColors.correctGreenDark;
        title = _skillLevel.description;
        subtitle = "Ôn tập bài học";
        buttonText = "ÔN TẬP +5 KN";
        break;
      case NodeStatus.inProgress:
        popupBgColor = AppColors.correctGreenLight;
        popupBorderColor = Colors.transparent;
        buttonTextColor = AppColors.correctGreenDark;
        title = _skillLevel.description;
        subtitle = "Bài học ${widget.lessonPosition}/${widget.totalLessons}";
        buttonText = "BẮT ĐẦU +25 KN";
        break;
      case NodeStatus.locked:
        popupBgColor = AppColors.swan;
        popupBorderColor = AppColors.hare;
        buttonTextColor = AppColors.hare;
        title = _skillLevel.description;
        subtitle = "Hãy hoàn thành các bài học trước để mở khóa";
        buttonText = "KHÓA";
        isLocked = true;
        break;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
              child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _removeOverlay,
            child: Container(color: Colors.transparent),
          )),
          Positioned(
            left: 20,
            right: 20,
            top: offset.dy - 170, // Đặt popup phía TRÊN node
            child: Material(
              color: Colors.transparent,
              child: _buildPopupContent(
                popupBgColor,
                popupBorderColor,
                buttonTextColor,
                title,
                subtitle,
                buttonText,
                isLocked,
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

  Widget _buildPopupContent(
      Color bgColor, Color borderColor, Color buttonTextColor,
      String title, String subtitle, String buttonText, bool isLocked) {
    const double tailSize = 20.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: const [
              BoxShadow(
                blurRadius: 8,
                color: Colors.black26,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: buttonTextColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                onPressed: () {
                  _removeOverlay();
                  if (!isLocked) {
                    // TODO: Xử lý sự kiện nhấn nút
                  }
                },
                child: Text(
                  buttonText,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -2),
          child: Transform.rotate(
            angle: pi / 4,
            child: Container(
              width: tailSize,
              height: tailSize,
              decoration: BoxDecoration(
                color: bgColor,
                border: Border(
                  bottom: BorderSide(color: borderColor, width: 2.0),
                  right: BorderSide(color: borderColor, width: 2.0),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  // --- BUILD: render node and handle tap/overlay ---
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        _controller.forward();
        await Future.delayed(const Duration(milliseconds: 70));
        _controller.reverse();

        if (_overlayEntry == null) {
          _showOverlay(context);
        } else {
          _removeOverlay();
        }
      },
      child: AnimatedBuilder(
        animation: _offsetAnim,
        builder: (context, child) {
          IconData iconData;
          switch (_status) {
            case NodeStatus.inProgress:
              iconData = Icons.star;
              break;
            case NodeStatus.completed:
              iconData = Icons.check;
              break;
            case NodeStatus.legendary:
              iconData = Icons.star;
              break;
            case NodeStatus.locked:
              iconData = Icons.lock_outline;
              break;
          }

          // --- SỬA ĐỔI: vẽ NODE RỘNG hơn CAO (width > height) ---
          // Use explicit base width and base height so node is wider than tall
          final double baseWidth = NodeTokens.baseWidth;
          final double baseHeight = baseWidth;
          final double shadowHeight = NodeTokens.shadowHeight;
          final double ringStrokeWidth = NodeTokens.ringStrokeWidth;
          final double ringGap = NodeTokens.ringGap;

          final double totalWidth = baseWidth;
          final double totalHeight = baseHeight + shadowHeight;

          Widget circleWidget = CustomPaint(
            size: Size(totalWidth, totalHeight),
            painter: EllipsePainter(
              offset: _offsetAnim.value,
              isReached: _status != NodeStatus.locked,
              icon: iconData,
              iconSize: NodeTokens.iconSize,
            ),
          );

          if (_status == NodeStatus.inProgress) {
            // Ensure ring padding is equal on all sides by sizing ring from the
            // larger of node width/height (including shadow) so the node is
            // centered inside the ring.
            final double nodeBoxSize = max(totalWidth, totalHeight);
            final double ringSize = nodeBoxSize + (ringGap * 2) + ringStrokeWidth;

            return Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: ringSize,
                  height: ringSize,
                  child: CustomPaint(
                    painter: ProgressRingPainter(
                      progress: _progress,
                      backgroundColor: AppColors.swan,
                      progressColor: AppColors.primary,
                      strokeWidth: ringStrokeWidth,
                    ),
                  ),
                ),
                // center node inside ring so distances to ring edges are equal
                circleWidget,
              ],
            );
          }

          return circleWidget;
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _removeOverlay();
    super.dispose();
  }
}

