import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/widgets/word_tiles/app_choice_tile_tokens.dart';

/// A tile widget for multiple choice options
/// Unlike WordTile, this tile:
/// - Always stays in default state (no selected state)
/// - Width fits content instead of fixed width
/// - Simpler design without complex animations
class ChoiceTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
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
          text,
          style: TextStyle(
            fontSize: AppChoiceTileTokens.fontSize,
            fontWeight: AppChoiceTileTokens.fontWeight,
            color: _getTextColor(),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (state) {
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
    switch (state) {
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
    switch (state) {
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

enum ChoiceTileState {
  defaults,
  selected,
  correct,
  incorrect,
}
