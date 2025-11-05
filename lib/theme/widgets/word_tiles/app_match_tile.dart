import 'package:flutter/material.dart';
import '../../colors.dart';
import 'app_match_tile_tokens.dart';
import '../../typography.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

/// Biểu thị các trạng thái trực quan của một ô trong bài tập match.
enum MatchTileState {
  /// Mặc định (nền trắng, viền xám).
  defaults,

  /// Đã được người dùng chọn (nền xanh nhạt, viền xanh).
  selected,

  /// Đã được xác nhận là đúng (nền xanh lá).
  correct,

  /// Đã được xác nhận là sai (nền đỏ).
  incorrect,

  /// Đã được nối đúng và vô hiệu hóa.
  disabled,
}

/// Một ô chọn từ dạng hình chữ nhật có thể nhấn, dùng trong bài tập Match.
/// Kích thước tự động căn chỉnh theo nội dung bên trong.
class MatchTile extends StatefulWidget {
  /// Từ/cụm từ hiển thị.
  final String word;

  /// Hàm được gọi khi nhấn.
  final VoidCallback? onPressed;

  /// Trạng thái trực quan của ô (mặc định, đã chọn, đã vô hiệu hóa).
  final MatchTileState state;

  /// Có hiển thị icon âm thanh thay vì text không.
  /// Khi true, sẽ hiển thị icon loa và ẩn text.
  final bool showSoundIcon;

  /// Chiều cao cố định cho tile (tùy chọn).
  /// Nếu null, sẽ sử dụng chiều cao mặc định từ tokens.
  final double? height;

  const MatchTile({
    Key? key,
    required this.word,
    this.onPressed,
    this.state = MatchTileState.defaults,
    this.showSoundIcon = false,
    this.height,
  }) : super(key: key);

  @override
  State<MatchTile> createState() => _MatchTileState();
}

class _MatchTileState extends State<MatchTile> with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _starOpacityAnimation;
  late Animation<double> _shakeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Scale animation for correct state
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.15).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 70.0,
      ),
    ]).animate(_animationController);
    
    // Star particles animation for correct state
    _starOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 20.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 80.0,
      ),
    ]).animate(_animationController);
    
    // Shake animation for incorrect state - simple shake left to right
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticIn,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  void didUpdateWidget(MatchTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger animation when transitioning to correct or incorrect state
    if (oldWidget.state != widget.state) {
      if (widget.state == MatchTileState.correct || widget.state == MatchTileState.incorrect) {
        _animationController.forward(from: 0.0);
      }
    }
  }

  double get _effectiveHeight => widget.height ?? AppMatchTileTokens.height.h;
  double get _effectiveBackgroundHeight => (widget.height != null)
      ? (widget.height! * (AppMatchTileTokens.backgroundHeight / AppMatchTileTokens.height))
      : AppMatchTileTokens.backgroundHeight.h;

  Color get _backgroundColor {
    switch (widget.state) {
      case MatchTileState.correct:
        return AppColors.correctGreenLight;
      case MatchTileState.incorrect:
        return AppColors.incorrectRedLight;
      case MatchTileState.selected:
        return AppColors.selectionBlueLight;
      case MatchTileState.disabled:
        return AppColors.swan;
      case MatchTileState.defaults:
        return AppColors.snow;
    }
  }

  Color get _shadowColor {
    switch (widget.state) {
      case MatchTileState.correct:
        return AppColors.correctGreenDark;
      case MatchTileState.incorrect:
        return AppColors.incorrectRedDark;
      case MatchTileState.selected:
        return AppColors.selectionBlueDark;
      case MatchTileState.disabled:
        return AppColors.hare;
      case MatchTileState.defaults:
        return AppColors.hare;
    }
  }

  Color get _textColor {
    switch (widget.state) {
      case MatchTileState.correct:
        return AppColors.wingOverlay;
      case MatchTileState.incorrect:
        return AppColors.tomato;
      case MatchTileState.selected:
        return AppColors.macaw;
      case MatchTileState.disabled:
        return AppColors.hare;
      case MatchTileState.defaults:
        return AppColors.bodyText;
    }
  }

  BorderSide get _borderSide {
    switch (widget.state) {
      case MatchTileState.defaults:
        return const BorderSide(color: AppColors.swan, width: 2.0);
      case MatchTileState.correct:
        return const BorderSide(color: AppColors.featherGreen, width: 2.0);
      case MatchTileState.incorrect:
        return const BorderSide(color: AppColors.cardinal, width: 2.0);
      case MatchTileState.selected:
        return const BorderSide(color: AppColors.macaw, width: 2.0);
      case MatchTileState.disabled:
        return const BorderSide(color: AppColors.hare, width: 2.0);
    }
  }

  TextStyle get _textStyle {
    final base = AppTypography.defaultTextTheme().titleMedium;
    return base!.copyWith(
      color: _textColor,
      fontSize: AppMatchTileTokens.textFontSize.sp,
      height: 1.2,
      fontWeight: FontWeight.w700,
    );
  }

  Widget _buildContent() {
    if (widget.showSoundIcon) {
      // Hiển thị icon âm thanh với sóng âm thanh
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.volume_up,
            color: _textColor,
            size: AppMatchTileTokens.iconSize.sp,
          ),
          SizedBox(width: 8.w),
          // Sóng âm thanh
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(5, (index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.w),
                child: Container(
                  width: 3.w,
                  height: _getSoundWaveHeight(index),
                  decoration: BoxDecoration(
                    color: _textColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              );
            }),
          ),
        ],
      );
    } else {
      // Hiển thị text
      return Text(
        widget.word,
        style: _textStyle,
        textAlign: TextAlign.center,
        softWrap: false,
        overflow: TextOverflow.visible,
      );
    }
  }
  
  double _getSoundWaveHeight(int index) {
    final heights = [12.h, 18.h, 24.h, 18.h, 12.h];
    return heights[index];
  }

  void _setPressed(bool value) {
    // Không cho phép animation press khi disabled
    if (widget.state == MatchTileState.disabled) return;
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }
  
  // Calculate shake offset using sine wave for smooth oscillation
  double _getShakeOffset(double value) {
    // Create a damped sine wave: amplitude * sin(frequency * value) * decay
    const frequency = 4.0; // Number of oscillations
    final amplitude = 8.0 * (1.0 - value); // Decreasing amplitude
    return amplitude * math.sin(frequency * math.pi * 2 * value);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEffectivelyDisabled = (widget.state == MatchTileState.disabled);
    final effectiveOnPressed = isEffectivelyDisabled ? null : widget.onPressed;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: effectiveOnPressed,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          // Calculate shake offset for incorrect state
          final shakeOffset = widget.state == MatchTileState.incorrect 
              ? _getShakeOffset(_shakeAnimation.value)
              : 0.0;
          
          return Transform.translate(
            // Apply shake animation for incorrect state
            offset: Offset(
              shakeOffset,
              _pressed ? 3.0.h : 0.0,
            ),
            child: Transform.scale(
              // Apply scale animation for correct state
              scale: widget.state == MatchTileState.correct ? _scaleAnimation.value : 1.0,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Main tile content
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: double.infinity, // Fill parent width
                    height: _effectiveHeight,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background layer với shadow và border
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          height: _effectiveBackgroundHeight,
                          decoration: BoxDecoration(
                            color: _backgroundColor,
                            borderRadius: BorderRadius.circular(AppMatchTileTokens.borderRadius.r),
                            border: Border.fromBorderSide(_borderSide),
                            boxShadow: _pressed
                                ? null
                                : [
                                    BoxShadow(
                                      color: _shadowColor,
                                      blurRadius: 0,
                                      offset: Offset(0, 4.h),
                                      spreadRadius: 0,
                                    )
                                  ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppMatchTileTokens.horizontalPadding.w,
                            ),
                            child: Center(
                              child: Opacity(
                                opacity: 0,
                                child: _buildContent(),
                              ),
                            ),
                          ),
                        ),

                        // Content layer
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: 4.0.h,
                            left: AppMatchTileTokens.horizontalPadding.w,
                            right: AppMatchTileTokens.horizontalPadding.w,
                          ),
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: _textStyle,
                            child: _buildContent(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Star particles animation (only visible when correct)
                  if (widget.state == MatchTileState.correct)
                    ..._buildStarParticles(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  List<Widget> _buildStarParticles() {
    final random = math.Random(widget.word.hashCode);
    return List.generate(8, (index) {
      final angle = (index * math.pi * 2 / 8);
      final distance = 30.0 + random.nextDouble() * 20.0;
      final dx = math.cos(angle) * distance * _starOpacityAnimation.value;
      final dy = math.sin(angle) * distance * _starOpacityAnimation.value;
      
      return Positioned(
        left: dx,
        top: dy,
        child: Opacity(
          opacity: _starOpacityAnimation.value,
          child: Icon(
            Icons.star,
            size: 12.sp + random.nextDouble() * 8.sp,
            color: AppColors.bee,
          ),
        ),
      );
    });
  }
}
