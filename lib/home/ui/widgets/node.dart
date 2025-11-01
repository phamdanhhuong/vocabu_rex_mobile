import 'package:flutter/material.dart';
import 'dart:math'; // Cần cho pi
import 'package:vocabu_rex_mobile/home/domain/entities/skill_level_entity.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

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
      duration: const Duration(milliseconds: 70),
    );

    _offsetAnim = Tween<double>(
      begin: 0,
      end: 4, // Giữ offset 4px
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
            ),
          ),
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
  
  // --- SỬA ĐỔI: THAY THẾ _buildNodeVisuals BẰNG build() CŨ ---
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
      // SỬA ĐỔI: Dùng lại logic CustomPaint
      child: AnimatedBuilder(
        animation: _offsetAnim,
        builder: (context, child) {
          
          // --- Logic chuyển đổi mới ---
          IconData iconData;
          switch (_status) {
            case NodeStatus.inProgress:
              // SỬA ĐỔI: Dùng icon sao cho nhất quán
              iconData = Icons.star;
              break;
            case NodeStatus.completed:
              iconData = Icons.check; // Icon "check"
              break;
            case NodeStatus.legendary:
              iconData = Icons.star; // Icon "sao"
              break;
            case NodeStatus.locked:
              iconData = Icons.lock_outline; // Icon "khóa"
              break;
          }
          // --- Kết thúc logic ---
          // --- SỬA ĐỔI BẮT ĐẦU TỪ ĐÂY ---
            
          // Sizes derived from icon size to avoid magic numbers.
          // These named ratios preserve previous visual proportions but scale
          // automatically if iconSize changes.
          const double baseIconSize = 24; // baseline icon glyph size
          const double ellipseHeightFactor = 2.7; // ellipse height = icon * factor
          const double ellipseAspect = 0.95; // previous width/height ratio

          final double ellipseHeight = baseIconSize * ellipseHeightFactor;
          final double ellipseWidth = ellipseHeight * ellipseAspect;

           // Compute ring size so it tightly encloses the inner capsule.
           // Use a stroke width that the painter will use, then compute the
           // minimal circle radius that covers the capsule's bounding box
           // (half-diagonal) plus half the stroke width and a small extra gap.
           const double ringStrokeWidth = 8.0;
           final double shadowH = min(8.0, ellipseHeight * 0.13);
           final double mainH = ellipseHeight - shadowH;

           // half extents of the capsule
           final double halfW = ellipseWidth / 2;
           final double halfH = mainH / 2;

           // minimal radius to cover capsule corners
           final double minRadius = sqrt(halfW * halfW + halfH * halfH);

           // padding: half stroke width + small margin based on icon size
           final double padding = (ringStrokeWidth / 2) + (baseIconSize * 0.15);

           final double requiredRadius = minRadius + padding;
           final double ringSize = requiredRadius * 2;

          // 1. Tạo widget Ellipse (luôn luôn có)
          Widget ellipseWidget = CustomPaint(
            size: Size(ellipseWidth, ellipseHeight), // Kích thước gốc
            painter: EllipsePainter(
              offset: _offsetAnim.value,
              status: _status, // Truyền status mới
              icon: iconData,
              iconSize: 24,
              shadowShiftFactor: widget.shadowShiftFactor,
            ),
          );

          // 2. Nếu là 'inProgress', bọc nó trong Stack với vòng tròn
          if (_status == NodeStatus.inProgress) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Lớp 1: Vòng tròn tiến độ
                SizedBox(
                  width: ringSize,
                  height: ringSize,
                  child: CustomPaint(
                    painter: _ProgressRingPainter(
                      progress: _progress, // 0.0 -> 1.0
                      backgroundColor: AppColors.swan, // Nền xám
                      progressColor: AppColors.primary, // Màu xanh
                      strokeWidth: ringStrokeWidth,
                    ),
                  ),
                ),
                // Lớp 2: Nút Ellipse (đặt ở trên)
                ellipseWidget,
              ],
            );
          }

          // 3. Nếu không, chỉ trả về ellipse
          return ellipseWidget;
            
          // --- KẾT THÚC SỬA ĐỔI ---
        },
      ),
    );
  }
  // --- KẾT THÚC SỬA ĐỔI ---

  @override
  void dispose() {
    _controller.dispose();
    _removeOverlay(); 
    super.dispose();
  }
}

// --- SỬA ĐỔI: NÂNG CẤP EllipsePainter ĐỂ DÙNG NodeStatus ---
class EllipsePainter extends CustomPainter {
  final double offset;
  final NodeStatus status; // Thay vì bool isReached
  final IconData icon;
  final double iconSize;
  final double shadowShiftFactor;

  EllipsePainter({
    required this.offset,
    required this.status, // Sửa ở đây
    required this.icon,
    required this.iconSize,
    required this.shadowShiftFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // --- Lấy màu dựa trên trạng thái ---
    Color primaryColor;
    Color secondaryColor;
    Color iconColor;

    switch (status) {
      case NodeStatus.legendary:
        primaryColor = AppColors.bee;
        secondaryColor = AppColors.fox;
        iconColor = AppColors.beakInner; // Màu nâu
        break;
      case NodeStatus.completed:
        primaryColor = AppColors.primary;
        secondaryColor = AppColors.wingOverlay;
        iconColor = Colors.white;
        break;
      case NodeStatus.inProgress:
         // SỬA ĐỔI: Xóa TODO, vì vòng tròn đã được vẽ bên ngoài
        primaryColor = AppColors.primary; // Giống completed
        secondaryColor = AppColors.wingOverlay;
        iconColor = Colors.white;
        break;
      case NodeStatus.locked:
        primaryColor = AppColors.swan;
        secondaryColor = AppColors.hare;
        iconColor = Colors.grey.shade700;
        break;
    }
    // --- Kết thúc lấy màu ---

    final paint = Paint()..color = secondaryColor; // Dùng màu bóng

  // Draw an inner ellipse-like capsule (rounded rectangle) and a shadow below it.
  final double w = size.width;
  final double h = size.height;

  // shadow height reserved at bottom (like your example: 65 total, main height ~57, shadow ~8)
  final double shadowH = min(8.0, h * 0.13);
  final double mainH = h - shadowH; // main capsule height

  // clamp animation offset so main shape doesn't go out of bounds
  final double maxOffset = min(6.0, h * 0.12);
  final double constrainedOffset = offset.clamp(-maxOffset, maxOffset);

  // Define main capsule rect (used for both main and shadow)
  final Rect mainRect = Rect.fromLTWH(0, 0 + constrainedOffset, w, mainH);
  // Make the capsule ends a bit rounder than before. Use a corner radius
  // based on mainH but clamp it so it doesn't exceed half the width.
  final double cornerRadius = min(mainH * 0.9, w / 2);
  final RRect mainR = RRect.fromRectAndRadius(mainRect, Radius.circular(cornerRadius));

  // Shadow: draw the same capsule shape as main but positioned underneath.
  // Use a slightly darker/transparent tint of the secondary color so it reads as a layer.
  final double shadowShift = shadowH * 0.6; // how far the shadow capsule sits below
  final RRect shadowR = RRect.fromRectAndRadius(
    mainRect.shift(Offset(0, shadowShift)),
    Radius.circular(cornerRadius),
  );
  final Paint shadowPaint = Paint()..color = secondaryColor.withOpacity(0.3);
  canvas.drawRRect(shadowR, shadowPaint);

  // Main capsule (rounded rectangle) on top
  paint.color = primaryColor;
  canvas.drawRRect(mainR, paint);
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: iconSize,
          fontWeight: FontWeight.bold,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: iconColor, // Dùng màu icon
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Tính scale đồng nhất để icon vừa trong main capsule.
    final availW = mainRect.width * 0.6;
    final availH = mainRect.height * 0.6;
    final available = min(availW, availH);
    final maxDim = max(textPainter.width, textPainter.height);
    final rawScale = maxDim > 0 ? (available / maxDim) : 1.0;
    // Không upscale lớn hơn kích thước font gốc để tránh icon quá bự; chỉ scale xuống khi cần
    final scaleFactor = min(1.0, rawScale);
    // Paint icon centered inside main capsule
    final centerX = mainRect.left + mainRect.width / 2;
    final centerY = mainRect.top + mainRect.height / 2;

    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.scale(scaleFactor, scaleFactor);
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant EllipsePainter oldDelegate) {
    return oldDelegate.offset != offset ||
        oldDelegate.status != status || // Sửa ở đây
        oldDelegate.icon != icon;
  }
}

// --- THÊM CLASS PAINTER MỚI VÀO CUỐI FILE ---
/// Painter cho vòng tròn tiến độ
class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  _ProgressRingPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    this.strokeWidth = 8.0, // Làm mỏng hơn 1 chút
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    // 1. Vẽ nền (màu xám)
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      pi * 2,
      false,
      backgroundPaint,
    );

    // 2. Vẽ tiến độ (màu xanh)
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
      
    final sweepAngle = pi * 2 * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

