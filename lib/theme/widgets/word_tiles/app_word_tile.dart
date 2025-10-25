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
        return AppColors.selectionBlueLight;
      case WordTileState.disabled:
        return AppColors.swan;
      case WordTileState.defaults:
      default:
        return AppColors.snow;
    }
  }

  // SỬA ĐỔI: Hoàn lại màu do bạn cung cấp
  Color get _shadowColor {
    switch (state) {
      case WordTileState.correct:
        return AppColors.correctGreenDark;
      case WordTileState.incorrect:
        return AppColors.incorrectRedDark;
      case WordTileState.selected:
        return AppColors.selectionBlueDark;
      case WordTileState.disabled:
        return AppColors.hare;
      case WordTileState.defaults:
      default:
        return AppColors.hare;
    }
  }

  // SỬA ĐỔI: Hoàn lại màu do bạn cung cấp
  Color get _textColor {
    switch (state) {
      case WordTileState.correct:
        return AppColors.wingOverlay;
      case WordTileState.incorrect:
        return AppColors.tomato;
      case WordTileState.selected:
        return AppColors.macaw;
      case WordTileState.disabled:
        return AppColors.hare;
      case WordTileState.defaults:
      default:
        return AppColors.bodyText;
    }
  }

  // SỬA ĐỔI: Hoàn lại màu do bạn cung cấp
  BorderSide get _borderSide {
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

  Widget _buildButtonLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(word, style: _textStyle, textAlign: TextAlign.center),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEffectivelyDisabled =
        (state == WordTileState.disabled || state == WordTileState.selected);
    final effectiveOnPressed = isEffectivelyDisabled ? null : onPressed;

    return GestureDetector(
      onTap: effectiveOnPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: _height,
        // SỬA ĐỔI LAYOUT: Dùng Stack(alignment: Alignment.center)
        child: Stack(
          // Căn giữa tất cả children (cả nền và chữ)
          alignment: Alignment.center,
          children: [
            // --- Lớp nền (với bóng và viền) ---
            // Không cần Positioned
            Container(
              height: _backgroundHeight,
              // Container này sẽ tự động co dãn theo child của nó
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
              // Trick: Dùng child Opacity để đo kích thước cho nền
              child: Opacity(
                opacity: 0,
                child: _buildButtonLabel(),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: _buildButtonLabel(),
            ),
          ],
        ),
      ),
    );
  }
}