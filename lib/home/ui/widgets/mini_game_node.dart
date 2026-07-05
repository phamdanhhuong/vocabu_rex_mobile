import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'node_tokens.dart';
import 'node_popup.dart';
import 'package:vocabu_rex_mobile/theme/widgets/speech_bubbles/speech_bubble.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/node_types.dart';

enum MiniGameType {
  arcade,
  gacha,
  portal,
  puzzle
}

class MiniGameNode extends StatefulWidget {
  final VoidCallback onTap;
  final int stars; // 0 to 3
  final MiniGameType type;
  final bool isLocked;

  const MiniGameNode({
    super.key, 
    required this.onTap, 
    this.stars = 0,
    this.type = MiniGameType.arcade,
    this.isLocked = false,
  });

  @override
  State<MiniGameNode> createState() => _MiniGameNodeState();
}

class _MiniGameNodeState extends State<MiniGameNode> with TickerProviderStateMixin {
  late final AnimationController _popupController;
  late final Animation<double> _popupScale;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _popupController = AnimationController(
      vsync: this,
      duration: NodeTokens.overlayAnimationDuration,
    );
    _popupScale = CurvedAnimation(
      parent: _popupController,
      curve: Curves.easeOutBack,
    );
  }

  void _showOverlay(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final nodeHeight = renderBox.size.height;
    const double popupMargin = NodeTokens.popupTailSpacing;
    final screenHeight = MediaQuery.of(context).size.height;
    const double popupEstimateHeight = NodeTokens.popupEstimateHeight;

    double topPos = offset.dy + nodeHeight + popupMargin;
    if (topPos + popupEstimateHeight > screenHeight - 20) {
      topPos = (offset.dy - popupEstimateHeight - popupMargin).clamp(
        20.0,
        screenHeight - 20.0,
      );
    }

    final Widget popupBody = NodePopup(
      title: "Thử Thách Giải Trí",
      subtitle: widget.isLocked
          ? "Hãy hoàn thành các bài học trước đó để mở khóa thử thách này nhé!"
          : widget.stars > 0 
          ? "Thành tích tốt nhất: ${widget.stars} ⭐️\nChơi lại để phá kỷ lục và nhận thêm phần thưởng!" 
          : "Nghỉ tay học tập, tham gia trò chơi nhỏ để săn thêm xu nào!",
      buttonText: widget.isLocked ? "BỊ KHOÁ" : (widget.stars > 0 ? "CHƠI LẠI" : "CHƠI NGAY"),
      isLocked: widget.isLocked,
      backgroundColor: widget.isLocked ? AppColors.hare : AppColors.macaw,
      borderColor: Colors.transparent,
      buttonTextColor: Colors.white,
      shadowColor: widget.isLocked ? AppColors.hare.withValues(alpha: 0.5) : AppColors.macaw.withValues(alpha: 0.8),
      status: widget.isLocked ? NodeStatus.locked : NodeStatus.completed,
      onPressed: widget.isLocked ? () {} : () {
        _removeOverlay().then((_) {
          widget.onTap();
        });
      },
    );

    final double screenWidth = MediaQuery.of(context).size.width;
    const double maxBubbleWidth = 400.0;
    final double availableWidth = screenWidth - (NodeTokens.overlayHorizontalPadding * 2);
    final double bubbleWidth = availableWidth > maxBubbleWidth ? maxBubbleWidth : availableWidth;

    final double bubbleLeftOnScreen = (screenWidth - bubbleWidth) / 2.0;
    final double nodeCenterGlobalX = offset.dx + (renderBox.size.width / 2.0);
    double tailLeft = nodeCenterGlobalX - bubbleLeftOnScreen - (NodeTokens.popupTailSize / 2.0);

    tailLeft = tailLeft.clamp(
      NodeTokens.popupTailClampMargin,
      bubbleWidth - NodeTokens.popupTailSize - NodeTokens.popupTailClampMargin,
    );

    final bool popupIsBelowNode = topPos > offset.dy;
    final double alignmentX = ((tailLeft) / bubbleWidth) * 2.0 - 1.0;
    final Alignment popupAlignment = Alignment(
      alignmentX.clamp(-1.0, 1.0),
      popupIsBelowNode ? -1.0 : 1.0,
    );

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _removeOverlay,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: topPos,
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: bubbleWidth,
                child: Material(
                  color: Colors.transparent,
                  child: ScaleTransition(
                    scale: _popupScale,
                    alignment: popupAlignment,
                    child: SpeechBubble(
                      backgroundColor: widget.isLocked ? AppColors.hare : AppColors.macaw,
                      borderColor: Colors.transparent,
                      shadowColor: widget.isLocked ? AppColors.hare.withValues(alpha: 0.5) : AppColors.macaw.withValues(alpha: 0.5),
                      variant: SpeechBubbleVariant.defaults,
                      tailDirection: popupIsBelowNode
                          ? SpeechBubbleTailDirection.top
                          : SpeechBubbleTailDirection.bottom,
                      tailOffset: tailLeft,
                      showShadow: true,
                      child: popupBody,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _popupController.forward();
  }

  Future<void> _removeOverlay() async {
    try {
      await _popupController.reverse();
    } catch (_) {}
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    // Hàng hiển thị 3 sao
    List<Widget> starWidgets = [];
    for (int i = 0; i < 3; i++) {
      bool isEarned = i < widget.stars;
      starWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Icon(
            Icons.star_rounded,
            color: isEarned ? AppColors.bee : AppColors.hare,
            size: 22,
            shadows: isEarned ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ] : null,
          ),
        ),
      );
    }

    String gameEmoji;
    switch (widget.type) {
      case MiniGameType.arcade: gameEmoji = '🎮'; break;
      case MiniGameType.gacha: gameEmoji = '🎰'; break;
      case MiniGameType.portal: gameEmoji = '🌀'; break;
      case MiniGameType.puzzle: gameEmoji = '🧩'; break;
    }

    Widget nodeContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Biểu tượng Joystick / Arcade có Hào quang
        Stack(
          alignment: Alignment.center,
          children: [
            // Ánh sáng Hào quang (Glow effect)
            if (!widget.isLocked)
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.macaw.withValues(alpha: 0.8),
                      blurRadius: 25,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),
            // Nền vòng tròn chứa biểu tượng tay cầm
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: widget.isLocked ? AppColors.swan : AppColors.macaw,
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.isLocked ? AppColors.hare : Colors.white,
                  width: 3,
                ),
                boxShadow: widget.isLocked ? null : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 0,
                    spreadRadius: -4,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Center(
                child: Opacity(
                  opacity: widget.isLocked ? 0.4 : 1.0,
                  child: Text(gameEmoji, style: const TextStyle(fontSize: 42)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Hàng Ngôi sao
        Row(
          mainAxisSize: MainAxisSize.min,
          children: starWidgets,
        ),
      ],
    );

    return GestureDetector(
      onTap: () {
        if (_overlayEntry == null) {
          _showOverlay(context);
        } else {
          _removeOverlay();
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6.0), // Không gian cho shadow
        child: nodeContent,
      ),
    );
  }

  @override
  void dispose() {
    _popupController.dispose();
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
    super.dispose();
  }
}
