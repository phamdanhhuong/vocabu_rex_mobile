import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';
import 'dart:math' as math;
import 'package:vocabu_rex_mobile/home/domain/entities/skill_level_entity.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'node_tokens.dart';
import 'node_popup.dart';
import 'node_visual.dart';
import 'ellipse_painter.dart';
import 'package:vocabu_rex_mobile/theme/widgets/speech_bubbles/speech_bubble.dart';
import 'node_top_overlay.dart';
import 'node_types.dart';
import 'package:vocabu_rex_mobile/energy/ui/blocs/energy_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/insufficient_energy_dialog.dart';

class LessonNode extends StatefulWidget {
  final SkillLevelEntity skillLevel;
  final int lessonPosition;
  final int totalLessons;
  final NodeStatus status;
  final double shadowShiftFactor;
  final Color? sectionColor;
  final Color? sectionShadowColor;

  const LessonNode({
    super.key,
    required this.skillLevel,
    required this.status,
    this.sectionColor,
    this.sectionShadowColor,
    this.lessonPosition = 0,
    this.totalLessons = 4,
    this.shadowShiftFactor = 0.6,
  });

  @override
  State<LessonNode> createState() => _LessonNodeState();
}

class _LessonNodeState extends State<LessonNode> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offsetAnim;

  late final AnimationController _topOverlayController;
  late final Animation<double> _topOverlayScale;
  late final AnimationController _topIdleController;

  late final AnimationController _popupController;
  late final Animation<double> _popupScale;

  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: NodeTokens.pressDuration,
    );
    _offsetAnim = Tween<double>(
      begin: 0.0,
      end: NodeTokens.offsetEnd,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _topOverlayController = AnimationController(
      vsync: this,
      duration: NodeTokens.overlayAnimationDuration,
    );
    _topOverlayScale = CurvedAnimation(
      parent: _topOverlayController,
      curve: Curves.easeOutBack,
    );

    _topIdleController =
        AnimationController(
          vsync: this,
          duration: NodeTokens.topOverlayFloatDuration,
        )..addListener(() {
          // rebuild for transform
          if (mounted) setState(() {});
        });

    _popupController = AnimationController(
      vsync: this,
      duration: NodeTokens.overlayAnimationDuration,
    );
    _popupScale = CurvedAnimation(
      parent: _popupController,
      curve: Curves.easeOutBack,
    );

    if (widget.status == NodeStatus.inProgress || widget.status == NodeStatus.jumpAhead) {
      _topOverlayController.value = 1.0;
      _topIdleController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant LessonNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      if (widget.status == NodeStatus.inProgress || widget.status == NodeStatus.jumpAhead) {
        _topOverlayController.forward();
        _topIdleController.repeat();
      } else {
        _topOverlayController.reverse();
        _topIdleController.stop();
      }
    }
  }

  double _estimateTopBubbleWidth(String text, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth < 360 
        ? NodeTokens.topOverlayFontSize * 0.9
        : NodeTokens.topOverlayFontSize;
    final double horizontalPadding = screenWidth < 360
        ? NodeTokens.topOverlayHorizontalPadding * 0.8
        : NodeTokens.topOverlayHorizontalPadding;
    
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    // include horizontal padding
    return tp.width + (horizontalPadding * 2) + 16.0;
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

    final _status = widget.status;
    final _skillLevel = widget.skillLevel;

    Color popupBgColor;
    Color popupBorderColor;
    Color buttonTextColor;
    String title;
    String subtitle;
    String buttonText;
    bool isLocked = false;

    switch (_status) {
      case NodeStatus.legendary:
        popupBgColor = AppColors.bee;
        popupBorderColor = Colors.transparent;
        buttonTextColor = AppColors.fox;
        title = _skillLevel.description;
        subtitle = "Bạn đã đạt cấp độ Huyền thoại!";
        buttonText = "ÔN TẬP +5 KN";
        break;
      case NodeStatus.completed:
        popupBgColor = widget.sectionColor ?? AppColors.correctGreenDark;
        popupBorderColor = Colors.transparent;
        buttonTextColor = popupBgColor;
        title = _skillLevel.description;
        subtitle = "Ôn tập bài học";
        buttonText = "ÔN TẬP +5 KN";
        break;
      case NodeStatus.inProgress:
        popupBgColor = widget.sectionColor ?? AppColors.correctGreenDark;
        popupBorderColor = Colors.transparent;
        buttonTextColor = popupBgColor;
        title = _skillLevel.description;
        subtitle = "Bài học ${widget.lessonPosition}/${widget.totalLessons}";
        buttonText = "BẮT ĐẦU +25 KN";
        break;
      case NodeStatus.jumpAhead:
        popupBgColor = widget.sectionColor ?? AppColors.correctGreenDark;
        popupBorderColor = Colors.transparent;
        buttonTextColor = popupBgColor;
        title = _skillLevel.description;
        subtitle = "Học vượt trước tiến độ";
        buttonText = "HỌC VƯỢT +25 KN";
        isLocked = false;
        break;
      case NodeStatus.locked:
        popupBgColor = AppColors.swan;
        popupBorderColor = Colors.transparent;
        buttonTextColor = AppColors.hare;
        title = _skillLevel.description;
        subtitle = "Hãy hoàn thành các bài học trước để mở khóa";
        buttonText = "KHÓA";
        isLocked = true;
        break;
    }

    final Color? bubbleShadowColor = widget.sectionShadowColor;

    final double overlayWidth =
        MediaQuery.of(context).size.width -
        (NodeTokens.overlayHorizontalPadding * 2);
    final double tailSize = NodeTokens.popupTailSize;
    final double nodeCenterGlobalX = offset.dx + (renderBox.size.width / 2.0);
    double tailLeft =
        nodeCenterGlobalX -
        NodeTokens.overlayHorizontalPadding -
        (tailSize / 2.0);
    tailLeft = tailLeft.clamp(
      NodeTokens.popupTailClampMargin,
      overlayWidth - tailSize - NodeTokens.popupTailClampMargin,
    );

    final bool popupIsBelowNode = topPos > offset.dy;

    final Widget popupBody = NodePopup(
      title: title,
      subtitle: subtitle,
      buttonText: buttonText,
      isLocked: isLocked,
      backgroundColor: popupBgColor,
      borderColor: popupBorderColor,
      buttonTextColor: buttonTextColor,
      shadowColor: bubbleShadowColor,
      status: _status,
      onPressed: () {
        // Remove the overlay first (animate out) then navigate.
        _removeOverlay().then((_) {
          if (!isLocked) {
            final lessons = _skillLevel.lessons;
            if (lessons == null || lessons.isEmpty) return;

            // Determine which lesson to open:
            // - If inProgress, open the user's current lesson position (convert to 0-based index)
            // - Otherwise open the first lesson
            int lessonIndex = 0;
            if (_status == NodeStatus.inProgress) {
              lessonIndex = (widget.lessonPosition > 0)
                  ? widget.lessonPosition - 1
                  : 0;
            }
            if (lessonIndex >= lessons.length) lessonIndex = lessons.length - 1;

            final lesson = lessons[lessonIndex];

            // Check energy before starting lesson
            final energyState = context.read<EnergyBloc>().state;
            int currentEnergy = 0;
            
            if (energyState is EnergyLoaded) {
              currentEnergy = energyState.response.currentEnergy;
            }
            
            // Require at least 1 energy to start a lesson
            if (currentEnergy < 1) {
              InsufficientEnergyDialog.show(
                context,
                currentEnergy: currentEnergy,
                requiredEnergy: 1,
              );
              return;
            }

            Navigator.pushNamed(
              context,
              '/exercise',
              arguments: {
                'lessonId': lesson.id,
                'lessonTitle': lesson.title,
                'isPronun': false,
              },
            );
          }
        });
      },
    );

    SpeechBubbleVariant bubbleVariant;
    switch (_status) {
      case NodeStatus.completed:
        bubbleVariant = SpeechBubbleVariant.correct;
        break;
      case NodeStatus.locked:
        bubbleVariant = SpeechBubbleVariant.neutral;
        break;
      case NodeStatus.legendary:
      case NodeStatus.inProgress:
      case NodeStatus.jumpAhead:
        bubbleVariant = SpeechBubbleVariant.defaults;
        break;
    }

    final double alignmentX = ((tailLeft) / overlayWidth) * 2.0 - 1.0;
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
            left: NodeTokens.overlayHorizontalPadding,
            right: NodeTokens.overlayHorizontalPadding,
            top: topPos,
            child: Material(
              color: Colors.transparent,
              child: ScaleTransition(
                scale: _popupScale,
                alignment: popupAlignment,
                child: SpeechBubble(
                  backgroundColor: popupBgColor,
                  borderColor: popupBorderColor,
                  shadowColor: bubbleShadowColor,
                  variant: bubbleVariant,
                  tailDirection: popupIsBelowNode
                      ? SpeechBubbleTailDirection.top
                      : SpeechBubbleTailDirection.bottom,
                  tailOffset: tailLeft,
                  showShadow: bubbleShadowColor != null,
                  child: popupBody,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    _topIdleController.stop();
    _topOverlayController.reverse();
    Overlay.of(context).insert(_overlayEntry!);
    _popupController.forward();
  }

  Future<void> _removeOverlay() async {
    try {
      await _popupController.reverse();
    } catch (_) {}
    _overlayEntry?.remove();
    _overlayEntry = null;
    _topOverlayController.forward();
    _topIdleController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    final _status = widget.status;
    final double baseWidth = NodeTokens.baseWidth;
    final double baseHeight = baseWidth;
    final double shadowHeight = NodeTokens.shadowHeight;
    final double ringStrokeWidth = NodeTokens.ringStrokeWidth;
    final double ringGap = NodeTokens.ringGap;

    final double totalWidth = baseWidth;
    final double totalHeight = baseHeight + shadowHeight;

    double _progress;
    if (_status == NodeStatus.completed) {
      _progress = 1.0;
    } else if (_status == NodeStatus.inProgress) {
      // Calculate progress based on actual lesson completion
      // Use (lessonPosition - 1) / totalLessons so that:
      // - 1/5 = 0%
      // - 2/5 = 20%
      // - 5/5 = 80%
      final double total = widget.totalLessons > 0
          ? widget.totalLessons.toDouble()
          : 1.0;
      final double current = (widget.lessonPosition - 1).toDouble();
      _progress = (current / total).clamp(0.0, 1.0);
    } else {
      _progress = 0.0;
    }

    IconData iconData;
    switch (_status) {
      case NodeStatus.inProgress:
        iconData = Icons.star;
        break;
      case NodeStatus.completed:
        iconData = Icons.check;
        break;
      case NodeStatus.legendary:
        iconData = Icons.star;
        break;
      case NodeStatus.locked:
        iconData = Icons.lock_outline;
        break;
      case NodeStatus.jumpAhead:
        iconData = Icons.star;
        break;
    }

    Widget circleWidget = CustomPaint(
      size: Size(totalWidth, totalHeight),
      painter: EllipsePainter(
        offset: _offsetAnim.value,
        isReached: _status != NodeStatus.locked,
        icon: iconData,
        iconSize: NodeTokens.iconSize,
        primaryColorOverride: widget.sectionColor,
        secondaryColorOverride:
            widget.sectionShadowColor ?? widget.sectionColor,
      ),
    );

    if (_status == NodeStatus.inProgress || _status == NodeStatus.jumpAhead) {
      final double nodeBoxSize = totalWidth > totalHeight
          ? totalWidth
          : totalHeight;
      final double ringSize = nodeBoxSize + (ringGap * 2) + ringStrokeWidth;

      final bool showTopOverlay = _status == NodeStatus.inProgress || _status == NodeStatus.jumpAhead;
      final double topOverlayExtra = showTopOverlay
          ? (NodeTokens.topOverlayHeight * NodeTokens.topOverlayExtraMultiplier)
          : 0.0;
      final double stackHeight = ringSize + topOverlayExtra;

      Widget ringAndNode = NodeVisual(
        ringSize: ringSize,
        ringStrokeWidth: ringStrokeWidth,
        progress: _progress,
        progressColor: widget.sectionColor ?? AppColors.primary,
        nodeChild: circleWidget,
      );

      final String topOverlayText = _status == NodeStatus.jumpAhead ? 'HỌC VƯỢT?' : 'BẮT ĐẦU';
      final double bubbleWidth = _estimateTopBubbleWidth(topOverlayText, context);
      Widget topOverlay = ScaleTransition(
        scale: _topOverlayScale,
        alignment: const Alignment(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(
            0.0,
            math.sin(_topIdleController.value * 2 * math.pi) *
                (NodeTokens.topOverlayFloatDistance / 2.0),
          ),
          child: TopOverlay(
            text: topOverlayText,
            sectionColor: widget.sectionColor,
            sectionShadowColor: widget.sectionShadowColor,
            tailOffset: bubbleWidth / 2.0,
          ),
        ),
      );

      return GestureDetector(
        onTap: () async {
          _controller.forward();
          await Future.delayed(const Duration(milliseconds: 70));
          _controller.reverse();
          if (_overlayEntry == null) {
            _showOverlay(context);
            ShowcaseView.get().dismiss();
          } else
            _removeOverlay();
        },
        child: SizedBox(
          width: ringSize,
          height: stackHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                top: showTopOverlay ? topOverlayExtra : 0.0,
                left: 0,
                right: 0,
                child: ringAndNode,
              ),
              if (showTopOverlay)
                Positioned(
                  top:
                      -(NodeTokens.topOverlayHeight *
                          NodeTokens.topOverlayTopMultiplier),
                  left: 0,
                  right: 0,
                  child: IgnorePointer(ignoring: true, child: topOverlay),
                ),
            ],
          ),
        ),
      );
    }

    // Not in-progress: simple tap behavior
    return GestureDetector(
      onTap: () async {
        _controller.forward();
        await Future.delayed(const Duration(milliseconds: 70));
        _controller.reverse();
        if (_overlayEntry == null) {
          _showOverlay(context);
          ShowcaseView.get().dismiss();
        } else
          _removeOverlay();
      },
      child: circleWidget,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _topOverlayController.dispose();
    _topIdleController.dispose();
    _popupController.dispose();
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
    super.dispose();
  }
}
