import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:confetti/confetti.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'node_tokens.dart';
import 'node_popup.dart';
import 'package:vocabu_rex_mobile/theme/widgets/speech_bubbles/speech_bubble.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/node_types.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/coin_flying_animation.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/header_keys.dart';

enum ChestNodeStatus {
  locked,
  readyToOpen,
  opened,
}

class ChestNode extends StatefulWidget {
  final ChestNodeStatus status;
  final VoidCallback onOpen;
  final String title;

  const ChestNode({
    super.key,
    required this.status,
    required this.onOpen,
    this.title = "Rương Kho Báu",
  });

  @override
  State<ChestNode> createState() => _ChestNodeState();
}

class _ChestNodeState extends State<ChestNode> with TickerProviderStateMixin {
  late final AnimationController _popupController;
  late final Animation<double> _popupScale;
  OverlayEntry? _overlayEntry;
  late ConfettiController _confettiController;

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
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
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

    final bool isLocked = widget.status == ChestNodeStatus.locked;
    final bool isOpened = widget.status == ChestNodeStatus.opened;

    Color popupBgColor = isLocked ? AppColors.swan : AppColors.bee;
    Color popupBorderColor = Colors.transparent;
    Color buttonTextColor = isLocked ? AppColors.hare : AppColors.fox;
    String subtitle = isLocked
        ? "Hãy hoàn thành bài học trước để mở rương"
        : (isOpened ? "Rương này đã được mở" : "Nhận phần thưởng của bạn!");
    String buttonText = isLocked ? "KHÓA" : (isOpened ? "ĐÃ MỞ" : "MỞ RƯƠNG");

    final Widget popupBody = NodePopup(
      title: widget.title,
      subtitle: subtitle,
      buttonText: buttonText,
      isLocked: isLocked || isOpened,
      backgroundColor: popupBgColor,
      borderColor: popupBorderColor,
      buttonTextColor: buttonTextColor,
      shadowColor: isLocked ? AppColors.hare : AppColors.legendaryButtonShadow,
      status: isLocked
          ? NodeStatus.locked
          : (isOpened ? NodeStatus.completed : NodeStatus.inProgress),
      onPressed: () {
        _removeOverlay().then((_) {
          if (widget.status == ChestNodeStatus.readyToOpen) {
            _playOpenAnimation();
          }
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
                      backgroundColor: popupBgColor,
                      borderColor: popupBorderColor,
                      shadowColor: isLocked ? AppColors.hare : AppColors.legendaryButtonShadow,
                      variant: isLocked ? SpeechBubbleVariant.neutral : SpeechBubbleVariant.defaults,
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

  void _playOpenAnimation() {
    // 1. Play Confetti
    _confettiController.play();

    // 2. Call the provided onOpen callback (which should update the state and call the API)
    widget.onOpen();

    // 3. Trigger Coin Flying Animation
    _triggerFlyingCoins();
  }

  void _triggerFlyingCoins() {
    // Get start position (this chest)
    final RenderBox chestBox = context.findRenderObject() as RenderBox;
    final Offset chestPosition = chestBox.localToGlobal(Offset(chestBox.size.width / 2, chestBox.size.height / 2));

    // Get end position (the coin header)
    Offset headerCoinPosition = const Offset(0, 0); // fallback
    if (HeaderKeys.coinKey.currentContext != null) {
      final RenderBox headerBox = HeaderKeys.coinKey.currentContext!.findRenderObject() as RenderBox;
      headerCoinPosition = headerBox.localToGlobal(Offset(headerBox.size.width / 2, headerBox.size.height / 2));
    }

    showCoinFlyingOverlay(context, chestPosition, headerCoinPosition, () {
      // Called when all coins finish flying. Trigger Jiggle.
      HeaderKeys.coinJiggleKey.currentState?.jiggle();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget chestWidget;

    if (widget.status == ChestNodeStatus.locked) {
      // Locked Chest
      chestWidget = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0,      0,      0,      1, 0,
        ]),
        child: Image.asset('assets/icons/chest_gold_close.png', width: 70, height: 70),
      );
    } else if (widget.status == ChestNodeStatus.readyToOpen) {
      // Ready Chest with glow
      chestWidget = Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.bee.withValues(alpha: 0.8),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          Image.asset('assets/icons/chest_gold_close.png', width: 80, height: 80),
        ],
      );
      // Add wobble
      chestWidget = Swing(
        infinite: true,
        duration: const Duration(milliseconds: 1500),
        child: chestWidget,
      );
    } else {
      // Opened Chest
      chestWidget = Opacity(
        opacity: 0.6,
        child: Image.asset('assets/icons/chest_gold_open.png', width: 70, height: 70),
      );
    }

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () {
            if (_overlayEntry == null) {
              _showOverlay(context);
            } else {
              _removeOverlay();
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: chestWidget,
          ),
        ),
        // Confetti Widget anchored to the chest
        Positioned(
          top: 0,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive, // radiate in all directions
            shouldLoop: false,
            colors: const [Colors.yellow, Colors.orange, Colors.amber, Colors.red],
            createParticlePath: drawStar, // custom particle shape
            numberOfParticles: 20,
            gravity: 0.5,
          ),
        ),
      ],
    );
  }

  /// A custom Path to paint stars.
  Path drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step), halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep), halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  @override
  void dispose() {
    _popupController.dispose();
    _confettiController.dispose();
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
    super.dispose();
  }
}
