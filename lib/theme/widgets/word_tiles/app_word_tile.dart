import 'package:flutter/material.dart';
import '../../colors.dart'; // Đảm bảo đường dẫn này chính xác
import 'app_word_tile_tokens.dart';
import '../../typography.dart';

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
class WordTile extends StatefulWidget {
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

  @override
  State<WordTile> createState() => _WordTileState();
}

class _WordTileState extends State<WordTile> {
  bool _pressed = false;
  static const Duration _pressDuration = Duration(milliseconds: 90);

  double get _height => AppWordTileTokens.height; // Giữ chiều cao cố định
  double get _backgroundHeight => AppWordTileTokens.backgroundHeight; // Chiều cao nền (thấp hơn để tạo bóng)

  Color get _backgroundColor {
    switch (widget.state) {
      case WordTileState.correct:
        return AppColors.correctGreenLight;
      case WordTileState.incorrect:
        return AppColors.incorrectRedLight;
      case WordTileState.selected:
        return AppColors.selectionBlueLight;
      case WordTileState.disabled:
        return AppColors.swan;
      case WordTileState.defaults:
        return AppColors.snow;
    }
  }

  Color get _shadowColor {
    switch (widget.state) {
      case WordTileState.correct:
        return AppColors.correctGreenDark;
      case WordTileState.incorrect:
        return AppColors.incorrectRedDark;
      case WordTileState.selected:
        return AppColors.selectionBlueDark;
      case WordTileState.disabled:
        return AppColors.hare;
      case WordTileState.defaults:
        return AppColors.hare;
    }
  }

  Color get _textColor {
    switch (widget.state) {
      case WordTileState.correct:
        return AppColors.wingOverlay;
      case WordTileState.incorrect:
        return AppColors.tomato;
      case WordTileState.selected:
        return AppColors.macaw;
      case WordTileState.disabled:
        return AppColors.hare;
      case WordTileState.defaults:
        return AppColors.bodyText;
    }
  }

  BorderSide get _borderSide {
    switch (widget.state) {
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
    }
  }

  TextStyle get _textStyle {
    // Use AppTypography tokens; fall back to simple style if missing
    final base = AppTypography.defaultTextTheme().titleLarge;
    return base!.copyWith(
      color: _textColor,
      fontSize: AppWordTileTokens.textFontSize,
      height: 1.0,
      fontWeight: FontWeight.w700,
    );
  }

  Widget _buildButtonLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(widget.word, style: _textStyle, textAlign: TextAlign.center),
    );
  }

  void _setPressed(bool value) {
    // disable press animation for disabled or selected tiles (matches existing behavior)
    if (widget.state == WordTileState.disabled || widget.state == WordTileState.selected) return;
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEffectivelyDisabled =
        (widget.state == WordTileState.disabled || widget.state == WordTileState.selected);
    final effectiveOnPressed = isEffectivelyDisabled ? null : widget.onPressed;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: effectiveOnPressed,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: _pressDuration,
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _pressed ? 3.0 : 0.0, 0),
        height: _height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // background layer with shadow and border
            AnimatedContainer(
              duration: _pressDuration,
              curve: Curves.easeOut,
              height: _backgroundHeight,
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(AppWordTileTokens.borderRadius),
                border: Border.fromBorderSide(_borderSide),
                boxShadow: _pressed
                    ? null
                    : [
                        BoxShadow(
                          // make disabled tile shadow lighter
                          color: _shadowColor,
                          blurRadius: 0,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        )
                      ],
              ),
              child: Opacity(opacity: 0, child: _buildButtonLabel()),
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