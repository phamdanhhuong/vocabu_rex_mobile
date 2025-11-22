import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/feed/domain/enums/feed_enums.dart';
import 'package:vocabu_rex_mobile/feed/ui/utils/feed_tokens.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class ReactionOverlay {
  static OverlayEntry? _currentOverlay;

  static void show({
    required BuildContext context,
    required GlobalKey buttonKey,
    required Function(String) onReactionSelected,
  }) {
    if (_currentOverlay != null) return;

    final RenderBox? renderBox = buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);

    _currentOverlay = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: hide,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              left: position.dx - FeedTokens.overlayOffsetHorizontal,
              top: position.dy - FeedTokens.overlayOffset,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: FeedTokens.overlayPaddingHorizontal, vertical: FeedTokens.overlayPaddingVertical),
                  decoration: BoxDecoration(
                    color: AppColors.snow,
                    borderRadius: BorderRadius.circular(FeedTokens.radiusRound),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.eel.withOpacity(FeedTokens.shadowOpacityLow),
                        blurRadius: FeedTokens.shadowBlurLow,
                        offset: const Offset(0, FeedTokens.elevationLow),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: ReactionType.values.map((reaction) {
                      return GestureDetector(
                        onTap: () {
                          hide();
                          onReactionSelected(reaction.value);
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: FeedTokens.overlayEmojiMargin),
                          child: Text(
                            reaction.emoji,
                            style: TextStyle(fontSize: FeedTokens.iconXl),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);
  }

  static void hide() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}
