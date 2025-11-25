import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/feed/domain/enums/feed_enums.dart';
import 'package:vocabu_rex_mobile/feed/ui/utils/feed_tokens.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class PostReactionButton extends StatefulWidget {
  final bool hasReacted;
  final bool isOwnPost;
  final ReactionType userReactionType;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final GlobalKey buttonKey;

  const PostReactionButton({
    Key? key,
    required this.hasReacted,
    required this.isOwnPost,
    required this.userReactionType,
    this.onTap,
    this.onLongPress,
    required this.buttonKey,
  }) : super(key: key);

  @override
  State<PostReactionButton> createState() => _PostReactionButtonState();
}

class _PostReactionButtonState extends State<PostReactionButton> {
  bool _pressed = false;
  static const Duration _pressDuration = Duration(milliseconds: 90);

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: widget.buttonKey,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: _pressDuration,
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _pressed ? 3.0 : 0.0, 0),
        width: FeedTokens.reactionButtonWidth,
        padding: EdgeInsets.symmetric(vertical: FeedTokens.reactionButtonPadding),
        decoration: BoxDecoration(
          color: widget.hasReacted ? AppColors.macawLight : AppColors.snow,
          borderRadius: BorderRadius.circular(FeedTokens.radiusL),
          border: Border.all(
            color: widget.hasReacted ? AppColors.macaw : AppColors.feedDivider,
            width: FeedTokens.borderThick,
          ),
          boxShadow: widget.hasReacted
              ? []
              : [
                  BoxShadow(
                    color: _pressed ? Colors.transparent : AppColors.swan,
                    offset: _pressed ? const Offset(0, 0) : const Offset(0, 2),
                    blurRadius: 0,
                  )
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.hasReacted ? widget.userReactionType.emoji : ReactionType.congrats.emoji,
              style: TextStyle(fontSize: FeedTokens.iconM),
            ),
            SizedBox(width: FeedTokens.spacingM),
            Text(
              widget.isOwnPost
                  ? 'CHIA SẺ'
                  : widget.hasReacted
                      ? widget.userReactionType.reactedText
                      : widget.userReactionType.actionText,
              style: TextStyle(
                fontSize: FeedTokens.fontS,
                fontWeight: FeedTokens.fontWeightExtraBold,
                color: widget.isOwnPost
                    ? AppColors.feedTextPrimary
                    : widget.hasReacted
                        ? AppColors.macaw
                        : AppColors.macaw,
                letterSpacing: FeedTokens.letterSpacingNormal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
