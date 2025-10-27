import 'package:flutter/material.dart';
import 'dart:math'; // Cần cho giá trị 'pi' để xoay
import '../../colors.dart'; // Đảm bảo đường dẫn này chính xác

/// Biểu thị hướng của "đuôi" bóng thoại.
enum SpeechBubbleTailDirection {
  left,
  right,
  top,
  bottom,
  none,
}

/// BiBbiểu thị trạng thái màu sắc của bóng thoại.
enum SpeechBubbleVariant {
  /// Trung tính (nền trắng, viền xám).
  neutral,

  /// Mặc định (nền xanh nhạt, viền xanh dương).
  defaults,

  /// Trạng thái đúng (nền xanh lá nhạt).
  correct,

  /// Trạng thái sai (nền đỏ nhạt).
  incorrect,
}

/// Một widget bóng thoại có thể tùy chỉnh hướng đuôi và màu sắc.
class SpeechBubble extends StatelessWidget {
  /// Nội dung bên trong bóng thoại.
  final Widget child;

  /// Trạng thái màu sắc (neutral, defaults, correct, incorrect).
  final SpeechBubbleVariant variant;

  /// Hướng của đuôi (left, right, top, bottom, none).
  final SpeechBubbleTailDirection tailDirection;

  /// Vị trí của đuôi:
  /// - Nếu hướng là `left` hoặc `right`: offset từ trên xuống.
  /// - Nếu hướng là `top` hoặc `bottom`: offset từ trái sang.
  final double tailOffset;

  final bool showShadow;

  const SpeechBubble({
    Key? key,
    required this.child,
    this.variant = SpeechBubbleVariant.neutral,
    this.tailDirection = SpeechBubbleTailDirection.left,
    this.tailOffset = 20.0,
    this.showShadow = true,
  }) : super(key: key);

  // --- Getters tạo kiểu dựa trên Variant ---

  Color get _backgroundColor {
    switch (variant) {
      case SpeechBubbleVariant.correct:
        return AppColors.correctGreenLight;
      case SpeechBubbleVariant.incorrect:
        return AppColors.incorrectRedLight;
      case SpeechBubbleVariant.defaults:
        return AppColors.selectionBlueLight;
      case SpeechBubbleVariant.neutral:
      default:
        return AppColors.snow;
    }
  }

  Color get _shadowColor {
    switch (variant) {
      case SpeechBubbleVariant.correct:
        return AppColors.correctGreenDark;
      case SpeechBubbleVariant.incorrect:
        return AppColors.incorrectRedDark;
      case SpeechBubbleVariant.defaults:
        return AppColors.selectionBlueDark;
      case SpeechBubbleVariant.neutral:
      default:
        return AppColors.hare;
    }
  }

  Color get _borderColor {
    switch (variant) {
      case SpeechBubbleVariant.correct:
        return AppColors.featherGreen;
      case SpeechBubbleVariant.incorrect:
        return AppColors.cardinal;
      case SpeechBubbleVariant.defaults:
        return AppColors.macaw;
      case SpeechBubbleVariant.neutral:
      default:
        return AppColors.swan;
    }
  }

  @override
  Widget build(BuildContext context) {
  const double tailSize = 16.0;
  const double borderRadius = 16.0;
  const double shadowVerticalOffset = 4.0; // Bóng luôn đổ xuống

    // --- Logic động cho Hướng (Direction) ---

    EdgeInsets mainPadding;
    EdgeInsets shadowPadding;
    double? tailLeft, tailRight, tailTop, tailBottom;
    double tailRotation;
    Border tailBorder;
    bool isHorizontalTail = tailDirection == SpeechBubbleTailDirection.left ||
        tailDirection == SpeechBubbleTailDirection.right;

    switch (tailDirection) {
      case SpeechBubbleTailDirection.left:
        mainPadding = EdgeInsets.only(left: tailSize / 2);
        shadowPadding =
            EdgeInsets.only(top: shadowVerticalOffset, left: tailSize / 2);
        tailLeft = -tailSize / 2;
        tailTop = tailOffset;
        tailRotation = -pi / 4; // -45 độ
        tailBorder = Border(
          top: BorderSide(color: _borderColor, width: 1.0),
          left: BorderSide(color: _borderColor, width: 1.0),
        );
        break;
      case SpeechBubbleTailDirection.right:
        mainPadding = EdgeInsets.only(right: tailSize / 2);
        shadowPadding =
            EdgeInsets.only(top: shadowVerticalOffset, right: tailSize / 2);
        tailRight = -tailSize / 2;
        tailTop = tailOffset;
        tailRotation = pi / 4; // 45 độ
        tailBorder = Border(
          top: BorderSide(color: _borderColor, width: 1.0),
          right: BorderSide(color: _borderColor, width: 1.0),
        );
        break;
      case SpeechBubbleTailDirection.bottom:
        mainPadding = EdgeInsets.only(bottom: tailSize / 2);
        shadowPadding = EdgeInsets.only(
            top: shadowVerticalOffset, bottom: tailSize / 2); // Bóng vẫn ở 'top'
        tailBottom = -tailSize / 2;
        tailLeft = tailOffset;
        tailRotation = pi / 4; // 45 độ
        tailBorder = Border(
          bottom: BorderSide(color: _borderColor, width: 1.0),
          right: BorderSide(color: _borderColor, width: 1.0),
        );
        break;
      case SpeechBubbleTailDirection.top:
        mainPadding = EdgeInsets.only(top: tailSize / 2);
        shadowPadding = EdgeInsets.only(
            top: shadowVerticalOffset +
                tailSize / 2); // Dịch bóng xuống bằng cả đuôi
        tailTop = -tailSize / 2;
        tailLeft = tailOffset;
        tailRotation = -pi / 4; // -45 độ
        tailBorder = Border(
          top: BorderSide(color: _borderColor, width: 1.0),
          left: BorderSide(color: _borderColor, width: 1.0),
        );
        break;
      case SpeechBubbleTailDirection.none:
      default:
        mainPadding = EdgeInsets.zero;
        shadowPadding = EdgeInsets.only(top: shadowVerticalOffset);
        tailLeft = null;
        tailRight = null;
        tailTop = null;
        tailBottom = null;
        tailRotation = 0;
        tailBorder = Border(); // Không viền
        break;
    }

    final Widget content = Padding(
      padding: const EdgeInsets.all(16.0),
      child: child,
    );

    return Stack(
      clipBehavior: Clip.none, // Cho phép đuôi tràn ra
      children: [
        // --- Lớp 1 & 2: ĐUÔI và THÂN (BÓNG) ---
        if (showShadow)
          Padding(
            padding: shadowPadding, // Dùng padding động
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Lớp 2: Thân (Bóng)
                Container(
                  width: double.infinity,
                  decoration: ShapeDecoration(
                    color: _shadowColor, // Dùng getter
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                  ),
                  child: Opacity(opacity: 0, child: content), // Đo kích thước
                ),
                // Lớp 1: Đuôi (Bóng) - DYNAMIC
                if (tailDirection != SpeechBubbleTailDirection.none)
                  Positioned(
                    left: tailLeft,
                    right: tailRight,
                    // Dịch chuyển bóng của đuôi cho đúng
                    top: isHorizontalTail ? tailTop! + shadowVerticalOffset : tailTop,
                    bottom: tailBottom,
                    child: Transform.rotate(
                      angle: tailRotation,
                      child: Container(
                        width: tailSize,
                        height: tailSize,
                        color: _shadowColor, // Dùng getter
                      ),
                    ),
                  ),
              ],
            ),
          ),

        // --- Lớp 3 & 4: ĐUÔI và THÂN (NỀN) ---
        Padding(
          padding: mainPadding, // Dùng padding động
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Lớp 4: Thân (Nền)
              Container(
                width: double.infinity,
                decoration: ShapeDecoration(
                  color: _backgroundColor, // Dùng getter
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    side: BorderSide(color: _borderColor, width: 1.0), // Dùng getter
                  ),
                ),
                child: content, // Nội dung thật
              ),
              // Lớp 3: Đuôi (Nền) - DYNAMIC
              if (tailDirection != SpeechBubbleTailDirection.none)
                Positioned(
                  left: tailLeft,
                  right: tailRight,
                  top: tailTop,
                  bottom: tailBottom,
                  child: Transform.rotate(
                    angle: tailRotation,
                    child: Container(
                      width: tailSize,
                      height: tailSize,
                      decoration: BoxDecoration(
                        color: _backgroundColor, // Dùng getter
                        border: tailBorder, // Dùng viền động
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

