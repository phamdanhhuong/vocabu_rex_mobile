import 'dart:async';
import 'package:flutter/material.dart';

/// Widget đếm thời gian tăng dần (ARCADE mode) hoặc hiển thị số lỗi (PUZZLE mode)
class MiniGameTimerWidget extends StatefulWidget {
  final bool isArcade;
  final int mistakesCount;
  final ValueChanged<int>? onTick; // trả về milliseconds đã trôi qua

  const MiniGameTimerWidget({
    super.key,
    required this.isArcade,
    this.mistakesCount = 0,
    this.onTick,
  });

  @override
  State<MiniGameTimerWidget> createState() => _MiniGameTimerWidgetState();
}

class _MiniGameTimerWidgetState extends State<MiniGameTimerWidget> {
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    if (widget.isArcade) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() => _seconds++);
          widget.onTick?.call(_seconds * 1000);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isArcade) {
      // Hiển thị đồng hồ đếm thời gian
      final isWarning = _seconds >= 120; // Vàng khi qua 2 phút
      final isDanger = _seconds >= 180; // Đỏ khi qua 3 phút
      final color = isDanger
          ? const Color(0xFFE53935)
          : isWarning
              ? const Color(0xFFFFA000)
              : const Color(0xFF1565C0);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_rounded, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              _formatTime(_seconds),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      );
    } else {
      // PUZZLE mode — hiển thị số lỗi
      final color = widget.mistakesCount == 0
          ? const Color(0xFF43A047)
          : widget.mistakesCount <= 2
              ? const Color(0xFFFFA000)
              : const Color(0xFFE53935);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              '${widget.mistakesCount} lỗi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      );
    }
  }
}
