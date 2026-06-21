import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/widgets/word_tiles/app_choice_tile_tokens.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vocabu_rex_mobile/feed/ui/widgets/components/confetti_overlay.dart';
import 'package:vocabu_rex_mobile/feed/domain/enums/feed_enums.dart';
import 'package:flutter/services.dart';

/// A tile widget for multiple choice options
class ChoiceTile extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final ChoiceTileState state;

  const ChoiceTile({
    super.key,
    required this.text,
    required this.onPressed,
    this.state = ChoiceTileState.defaults,
  });

  @override
  State<ChoiceTile> createState() => _ChoiceTileState();
}

class _ChoiceTileState extends State<ChoiceTile> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  AnimationController? _shakeController;
  bool _hasPlayedEffect = false;
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(ChoiceTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) {
      if (widget.state == ChoiceTileState.incorrect) {
        _shakeController?.forward(from: 0.0);
      } else if (widget.state == ChoiceTileState.correct && !_hasPlayedEffect) {
        _hasPlayedEffect = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _playCorrectParticles();
          }
        });
      }
    }
  }

  void _playCorrectParticles() {
    final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final offset = renderBox.localToGlobal(Offset(renderBox.size.width / 2, renderBox.size.height / 2));
      ConfettiOverlay.show(context, offset, ReactionType.congrats);
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShakeX(
      manualTrigger: true,
      controller: (c) => _shakeController = c,
      child: GestureDetector(
        onTapDown: (_) => _scaleController.forward(),
        onTapUp: (_) {
          _scaleController.reverse();
          widget.onPressed();
        },
        onTapCancel: () => _scaleController.reverse(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            key: _key,
            padding: EdgeInsets.symmetric(
              horizontal: AppChoiceTileTokens.paddingHorizontal,
              vertical: AppChoiceTileTokens.paddingVertical,
            ),
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              borderRadius: BorderRadius.circular(AppChoiceTileTokens.borderRadius),
              border: Border.all(
                color: _getBorderColor(),
                width: AppChoiceTileTokens.borderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  offset: const Offset(0, 4),
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Text(
              widget.text,
              style: TextStyle(
                fontSize: AppChoiceTileTokens.fontSize,
                fontWeight: AppChoiceTileTokens.fontWeight,
                color: _getTextColor(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (widget.state) {
      case ChoiceTileState.defaults:
        return AppChoiceTileTokens.backgroundColorDefault;
      case ChoiceTileState.selected:
        return AppChoiceTileTokens.backgroundColorSelected;
      case ChoiceTileState.correct:
        return AppChoiceTileTokens.backgroundColorCorrect;
      case ChoiceTileState.incorrect:
        return AppChoiceTileTokens.backgroundColorIncorrect;
    }
  }

  Color _getBorderColor() {
    switch (widget.state) {
      case ChoiceTileState.defaults:
        return AppChoiceTileTokens.borderColorDefault;
      case ChoiceTileState.selected:
        return AppChoiceTileTokens.borderColorSelected;
      case ChoiceTileState.correct:
        return AppChoiceTileTokens.borderColorCorrect;
      case ChoiceTileState.incorrect:
        return AppChoiceTileTokens.borderColorIncorrect;
    }
  }

  Color _getTextColor() {
    switch (widget.state) {
      case ChoiceTileState.defaults:
        return AppChoiceTileTokens.textColorDefault;
      case ChoiceTileState.selected:
        return AppChoiceTileTokens.textColorSelected;
      case ChoiceTileState.correct:
        return AppChoiceTileTokens.textColorCorrect;
      case ChoiceTileState.incorrect:
        return AppChoiceTileTokens.textColorIncorrect;
    }
  }
}

enum ChoiceTileState { defaults, selected, correct, incorrect }
