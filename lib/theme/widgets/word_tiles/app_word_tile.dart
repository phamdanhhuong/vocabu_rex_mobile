import 'package:flutter/material.dart';
import '../../colors.dart'; // Đảm bảo đường dẫn này chính xác

/// Biểu thị các trạng thái trực quan của một ô chọn từ.
enum WordTileState {
  /// Mặc định (nền trắng, viền xám).
  defaults,

  /// Đã được người dùng chọn (nền xám nhạt, viền xanh).
  selected,

  /// Đã được xác nhận là đúng (nền xanh lá).
  correct,

  /// Đã được xác nhận là sai (nền đỏ).
  incorrect,

  /// Bị vô hiệu hóa (thường là sau khi đã được chọn).
  disabled,
}

/// Một ô chọn từ có thể nhấn, dùng trong các bài học.
/// Giống AppButton, nó dùng Stack để tạo hiệu ứng 3D với bóng.
class WordTile extends StatelessWidget {
  /// Từ/cụm từ hiển thị.
  final String word;

  /// Hàm được gọi khi nhấn.
  final VoidCallback onPressed;

  /// Trạng thái trực quan của ô (mặc định, đã chọn, đúng, sai).
  final WordTileState state;

  const WordTile({
    Key? key,
    required this.word,
    required this.onPressed,
    this.state = WordTileState.defaults,
  }) : super(key: key);

  // --- Getters tạo kiểu ---

  double get _height => 50; // Giữ chiều cao cố định
  double get _backgroundHeight => 46; // Chiều cao nền (thấp hơn để tạo bóng)

  Color get _backgroundColor {
    switch (state) {
      case WordTileState.correct:
        return AppColors.correctGreenLight;
      case WordTileState.incorrect:
        return AppColors.incorrectRedLight;
      case WordTileState.selected:
        return AppColors.selectionBlueLight; // Xám rất nhạt
      case WordTileState.disabled:
        return AppColors.swan; // Xám nhạt
      case WordTileState.defaults:
      default:
        return AppColors.snow; // Trắng
    }
  }

  Color get _shadowColor {
    switch (state) {
      case WordTileState.correct:
        return AppColors.correctGreenDark; // Xanh lá đậm
      case WordTileState.incorrect:
        return AppColors.incorrectRedDark; // SỬA ĐỔI: Đổi sang màu đỏ đậm
      case WordTileState.selected:
        return AppColors.selectionBlueDark; // Xám
      case WordTileState.disabled:
        return AppColors.hare; // Không bóng khi disabled
      case WordTileState.defaults:
      default:
        return AppColors.hare; // Xám
    }
  }

  Color get _textColor {
    switch (state) {
      case WordTileState.correct:
        return AppColors.correctGreenDark; // Trắng
      case WordTileState.incorrect:
        return AppColors.incorrectRedDark; // Trắng
      case WordTileState.selected:
        return AppColors.selectionBlueDark; // Chữ xanh dương
      case WordTileState.disabled:
        return AppColors.hare; // Xám
      case WordTileState.defaults:
      default:
        return AppColors.bodyText; // Xám đậm
    }
  }

  BorderSide get _borderSide {
    // Chỉ trạng thái 'defaults' và 'selected' có viền
    switch (state) {
      case WordTileState.defaults:
        return const BorderSide(color: AppColors.swan, width: 1.0);
      case WordTileState.correct:
        return const BorderSide(color: AppColors.featherGreen, width: 1.0);
      case WordTileState.incorrect:
        return const BorderSide(color: AppColors.cardinal, width: 1.0);
      case WordTileState.selected:
        return const BorderSide(color: AppColors.macaw, width: 1.0);
      case WordTileState.disabled:
        return const BorderSide(color: AppColors.hare, width: 1.0);
      default:
        return BorderSide.none;
    }
  }

  TextStyle get _textStyle {
    return TextStyle(
      fontFamily: 'DuolingoFeather', // Giả sử bạn có font này
      fontWeight: FontWeight.w700,
      fontSize: 18,
      color: _textColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Nút bị vô hiệu hóa khi ở trạng thái 'disabled' hoặc 'selected'
    final bool isEffectivelyDisabled =
        (state == WordTileState.disabled || state == WordTileState.selected);
    final effectiveOnPressed = isEffectivelyDisabled ? null : onPressed;

    // Nội dung của nút, có padding bên trong
    final buttonLabel = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        word,
        style: _textStyle,
        textAlign: TextAlign.center,
      ),
    );

    return GestureDetector(
      onTap: effectiveOnPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: _height,
        // Container ngoài không có width, để nó tự co dãn theo Stack
        child: Stack(
          // Stack sẽ tự co dãn theo chiều rộng của Align(child: buttonLabel)
          children: [
            // Lớp nền (với bóng và viền)
            Positioned(
              left: 0,
              top: 0,
              // Positioned không có width/right, nó sẽ co dãn theo Stack
              child: Container(
                height: _backgroundHeight,
                // Container này cũng không có width, nó sẽ co dãn theo
                // 'buttonLabel' bên dưới nhờ Stack
                decoration: ShapeDecoration(
                  color: _backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: _borderSide,
                  ),
                  shadows: [
                    BoxShadow(
                      color: _shadowColor,
                      blurRadius: 0,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    )
                  ],
                ),
                // Trick: Thêm 1 child rỗng với padding giống
                // buttonLabel để đảm bảo nó có cùng kích thước
                // (vì Positioned container không có child)
                child: Opacity(
                  opacity: 0,
                  child: buttonLabel,
                ),
              ),
            ),

            // Lớp nội dung (Text)
            // Căn giữa theo chiều dọc
            Align(
              alignment: Alignment.center,
              child: buttonLabel,
            ),
          ],
        ),
      ),
    );
  }
}

