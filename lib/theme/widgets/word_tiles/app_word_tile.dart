import 'package:flutter/material.dart';
import '../../colors.dart'; // Đảm bảo đường dẫn này chính xác
import 'app_word_tile_tokens.dart';
import '../../typography.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  /// Optional square size. When provided, the tile will be a square of this
  /// size represents the desired tile height. When provided, the tile will
  /// use this height. You can optionally provide an explicit `width` so the
  /// tile becomes a fixed size rectangle; when `width` is null and `size` is
  /// provided the tile width will be unconstrained (so it can expand to fit
  /// the text). If `size` is null the component uses the design token
  /// default height and the width falls back to a matching token.
  final double? size;
  /// Optional explicit width for the tile. When provided, this width is used
  /// directly (in logical pixels) and overrides the unconstrained behavior.
  final double? width;

  const WordTile({
    Key? key,
    required this.word,
    required this.onPressed,
    this.state = WordTileState.defaults,
  this.size,
  this.width,
  }) : super(key: key);

  @override
  State<WordTile> createState() => _WordTileState();
}

class _WordTileState extends State<WordTile> {
  bool _pressed = false;

  // Height follows the provided `size` (interpreted as height) if given;
  // otherwise use the design token height. Width is left unconstrained when
  // a height is provided so the tile can expand horizontally to fit text.
  double get _effectiveHeight => widget.size ?? AppWordTileTokens.height.h;
  double get _effectiveBackgroundHeight => (widget.size != null)
      ? (widget.size! * (AppWordTileTokens.backgroundHeight / AppWordTileTokens.height))
      : AppWordTileTokens.backgroundHeight.h;
  double? get _effectiveWidth {
    // If an explicit width is provided, use it. Otherwise, if a height was
    // supplied we leave width unconstrained (null) so the tile can expand
    // horizontally to fit content. If neither size nor width provided,
    // fall back to the token-based width.
    if (widget.width != null) return widget.width;
    if (widget.size != null) return null;
    return AppWordTileTokens.height.w;
  }

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
      // scale the font size to match ScreenUtil usage in layouts
      fontSize: AppWordTileTokens.textFontSize.sp,
      height: 1.0,
      fontWeight: FontWeight.w700,
    );
  }

  Widget _buildButtonLabel() {
    return Padding(
      // scale horizontal padding to match measurement logic in match.dart
      padding: EdgeInsets.symmetric(horizontal: AppWordTileTokens.horizontalPadding.w),
      child: Text(
        widget.word,
        style: _textStyle,
        textAlign: TextAlign.center,
        softWrap: false,
        overflow: TextOverflow.visible,
      ),
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
      child: Transform.translate(
        offset: Offset(0, _pressed ? 3.0.h : 0.0),
        child: Container(
          height: _effectiveHeight,
          width: _effectiveWidth,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // background layer with shadow and border
              Container(
                height: _effectiveBackgroundHeight,
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  borderRadius: BorderRadius.circular(AppWordTileTokens.borderRadius.r),
                  border: Border.fromBorderSide(_borderSide),
                  boxShadow: _pressed
                      ? null
                      : [
                          BoxShadow(
                            // make disabled tile shadow lighter
                            color: _shadowColor,
                            blurRadius: 0,
                            offset: Offset(0, 4.h),
                            spreadRadius: 0,
                          )
                        ],
                ),
                child: Opacity(opacity: 0, child: _buildButtonLabel()),
              ),

              Padding(
                // small bottom offset, scaled as well
                padding: EdgeInsets.only(bottom: 4.0.h),
                child: _buildButtonLabel(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}