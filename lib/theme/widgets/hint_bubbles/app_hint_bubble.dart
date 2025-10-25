import 'package:flutter/material.dart';
import 'dart:math'; // Cần cho giá trị 'pi' để xoay
import '../../colors.dart'; // Đảm bảo đường dẫn này chính xác

/// Biểu thị các trạng thái trực quan của bóng thoại đề bài.
enum HintBubbleVariant {
  /// Mặc định (màu xanh dương)
  defaults,

  /// Trạng thái đúng (màu xanh lá)
  correct,

  /// Trạng thái sai (màu đỏ)
  incorrect,

  /// Trạng thái trung tính (màu trắng/xám, ví dụ: cho phần hướng dẫn)
  neutral,
}

/// Một widget bóng thoại để hiển thị đề bài/câu hỏi trong bài học.
/// Nó có một "đuôi" ở giữa, bên dưới.
class HintBubble extends StatelessWidget {
  /// Tiêu đề của đề bài (ví dụ: "Translate this sentence").
  final String title;

  /// Widget nội dung chính (ví dụ: Text câu hỏi, nút audio).
  final Widget child;

  /// Trạng thái trực quan (mặc định, đúng, sai, trung tính).
  final HintBubbleVariant variant;

  const HintBubble({
    Key? key,
    required this.title,
    required this.child,
    this.variant = HintBubbleVariant.defaults,
  }) : super(key: key);

  // --- Getters tạo kiểu ---

  Color get _backgroundColor {
    switch (variant) {
      case HintBubbleVariant.correct:
        return AppColors.correctGreenLight;
      case HintBubbleVariant.incorrect:
        return AppColors.incorrectRedLight;
      case HintBubbleVariant.neutral:
        return AppColors.snow;
      case HintBubbleVariant.defaults:
      default:
        return AppColors.selectionBlueLight;
    }
  }

  Color get _shadowColor {
    switch (variant) {
      case HintBubbleVariant.correct:
        return AppColors.correctGreenDark;
      case HintBubbleVariant.incorrect:
        return AppColors.incorrectRedDark;
      case HintBubbleVariant.neutral:
        return AppColors.hare;
      case HintBubbleVariant.defaults:
      default:
        return AppColors.selectionBlueDark;
    }
  }

  Color get _borderColor {
    // Logic viền này được sao chép từ WordTile cho nhất quán
    switch (variant) {
      case HintBubbleVariant.correct:
        return AppColors.featherGreen;
      case HintBubbleVariant.incorrect:
        return AppColors.cardinal;
      case HintBubbleVariant.neutral:
        return AppColors.swan;
      case HintBubbleVariant.defaults:
      default:
        return AppColors.macaw;
    }
  }

  Color get _titleColor {
    // Logic màu chữ này được sao chép từ WordTile
    switch (variant) {
      case HintBubbleVariant.correct:
        return AppColors.correctGreenDark;
      case HintBubbleVariant.incorrect:
        return AppColors.incorrectRedDark;
      case HintBubbleVariant.neutral:
        return AppColors.bodyText;
      case HintBubbleVariant.defaults:
      default:
        return AppColors.selectionBlueDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    const double tailSize = 20.0;
    const double borderRadius = 16.0;
    const double backgroundVerticalOffset = 4.0; // Khoảng cách bóng

    // Widget nội dung bên trong, tách ra để dùng 2 lần (cho đo lường và hiển thị)
    final Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'DuolingoFeather',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: _titleColor, // SỬA ĐỔI: Dùng getter
            ),
          ),
          const SizedBox(height: 12),
          // 'child' là nơi bạn sẽ đặt Text câu hỏi và nút Audio
          child,
        ],
      ),
    );

    return Container(
      width: double.infinity, // Mở rộng tối đa
      // Thêm margin dưới để đuôi không bị cắt
      margin: const EdgeInsets.only(bottom: tailSize / 2),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none, // Cho phép đuôi tràn ra ngoài
        children: [
          // --- Lớp 1 & 2: ĐUÔI và THÂN (BÓNG) ---
          Padding(
            // Đẩy lớp bóng xuống 4px
            padding: const EdgeInsets.only(top: backgroundVerticalOffset),
            child: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                // Lớp 2: Thân (Bóng)
                Container(
                  width: double.infinity,
                  decoration: ShapeDecoration(
                    color: _shadowColor, // SỬA ĐỔI: Dùng getter
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                  ),
                  // Dùng Opacity để đo kích thước
                  child: Opacity(opacity: 0, child: content),
                ),
                // Lớp 1: Đuôi (Bóng)
                Positioned(
                  bottom: -tailSize / 2, // Treo ở dưới cùng
                  child: Transform.rotate(
                    angle: pi / 4, // Xoay 45 độ
                    child: Container(
                      width: tailSize,
                      height: tailSize,
                      color: _shadowColor, // SỬA ĐỔI: Dùng getter
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- Lớp 3 & 4: ĐUÔI và THÂN (NỀN) ---
          // Lớp này không bị `Padding` đẩy xuống, nên nó sẽ ở trên lớp bóng
          Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              // Lớp 4: Thân (Nền)
              Container(
                width: double.infinity,
                decoration: ShapeDecoration(
                  color: _backgroundColor, // SỬA ĐỔI: Dùng getter
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    // SỬA ĐỔI: Dùng getter cho viền
                    side: BorderSide(color: _borderColor, width: 1.0),
                  ),
                ),
                child: content, // Hiển thị nội dung thật
              ),
              // Lớp 3: Đuôi (Nền)
              Positioned(
                bottom: -tailSize / 2,
                child: Transform.rotate(
                  angle: pi / 4,
                  child: Container(
                    width: tailSize,
                    height: tailSize,
                    decoration: BoxDecoration(
                      color: _backgroundColor, // SỬA ĐỔI: Dùng getter
                      // Thêm viền cho 2 cạnh dưới của đuôi
                      border: Border(
                        bottom: BorderSide(color: _borderColor, width: 1.0),
                        right: BorderSide(color: _borderColor, width: 1.0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

