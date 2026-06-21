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
  final int globalIndex;

  const LessonNode({
    super.key,
    required this.skillLevel,
    required this.status,
    this.sectionColor,
    this.sectionShadowColor,
    this.lessonPosition = 0,
    this.totalLessons = 4,
    this.shadowShiftFactor = 0.6,
    this.globalIndex = 0,
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

  late final AnimationController _shinyController;
  late final Animation<double> _shinyAnimation;

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

    _shinyController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _shinyAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shinyController, curve: Curves.easeInOut),
    )..addListener(() {
        if (mounted) setState(() {});
      });

    if (widget.status == NodeStatus.inProgress ||
        widget.status == NodeStatus.jumpAhead) {
      _topOverlayController.value = 1.0;
      _topIdleController.repeat();
    }

    if (widget.status == NodeStatus.completed || widget.status == NodeStatus.legendary) {
      _shinyController.repeat(reverse: false);
    }
  }

  @override
  void didUpdateWidget(covariant LessonNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      if (widget.status == NodeStatus.inProgress ||
          widget.status == NodeStatus.jumpAhead) {
        _topOverlayController.forward();
        _topIdleController.repeat();
      } else {
        _topOverlayController.reverse();
        _topIdleController.stop();
      }

      if (widget.status == NodeStatus.completed || widget.status == NodeStatus.legendary) {
        _shinyController.repeat(reverse: false);
      } else {
        _shinyController.stop();
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

    final status = widget.status;
    final skillLevel = widget.skillLevel;

    Color popupBgColor;
    Color popupBorderColor;
    Color buttonTextColor;
    String title;
    String subtitle;
    String buttonText;
    bool isLocked = false;

    switch (status) {
      case NodeStatus.legendary:
        popupBgColor = AppColors.bee;
        popupBorderColor = Colors.transparent;
        buttonTextColor = AppColors.fox;
        title = skillLevel.description;
        subtitle = "Bạn đã đạt cấp độ Huyền thoại!";
        buttonText = "ÔN TẬP +5 KN";
        break;
      case NodeStatus.completed:
        popupBgColor = widget.sectionColor ?? AppColors.correctGreenDark;
        popupBorderColor = Colors.transparent;
        buttonTextColor = popupBgColor;
        title = skillLevel.description;
        subtitle = "Ôn tập bài học";
        buttonText = "ÔN TẬP +5 KN";
        break;
      case NodeStatus.inProgress:
        popupBgColor = widget.sectionColor ?? AppColors.correctGreenDark;
        popupBorderColor = Colors.transparent;
        buttonTextColor = popupBgColor;
        title = skillLevel.description;
        subtitle = "Bài học ${widget.lessonPosition}/${widget.totalLessons}";
        buttonText = "BẮT ĐẦU +25 KN";
        break;
      case NodeStatus.jumpAhead:
        popupBgColor = widget.sectionColor ?? AppColors.correctGreenDark;
        popupBorderColor = Colors.transparent;
        buttonTextColor = popupBgColor;
        title = skillLevel.description;
        subtitle = "Học vượt trước tiến độ";
        buttonText = "HỌC VƯỢT +25 KN";
        isLocked = false;
        break;
      case NodeStatus.locked:
        popupBgColor = AppColors.swan;
        popupBorderColor = Colors.transparent;
        buttonTextColor = AppColors.hare;
        title = skillLevel.description;
        subtitle = "Hãy hoàn thành các bài học trước để mở khóa";
        buttonText = "KHÓA";
        isLocked = true;
        break;
    }

    Color? bubbleShadowColor;
    switch (status) {
      case NodeStatus.locked:
        bubbleShadowColor = AppColors.hare;
        break;
      case NodeStatus.legendary:
        bubbleShadowColor = AppColors.legendaryButtonShadow;
        break;
      default:
        bubbleShadowColor = widget.sectionShadowColor;
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    const double maxBubbleWidth = 400.0;
    final double availableWidth =
        screenWidth - (NodeTokens.overlayHorizontalPadding * 2);
    final double bubbleWidth =
        availableWidth > maxBubbleWidth ? maxBubbleWidth : availableWidth;

    final double bubbleLeftOnScreen = (screenWidth - bubbleWidth) / 2.0;

    final double tailSize = NodeTokens.popupTailSize;
    final double nodeCenterGlobalX = offset.dx + (renderBox.size.width / 2.0);

    double tailLeft =
        nodeCenterGlobalX - bubbleLeftOnScreen - (tailSize / 2.0);

    tailLeft = tailLeft.clamp(
      NodeTokens.popupTailClampMargin,
      bubbleWidth - tailSize - NodeTokens.popupTailClampMargin,
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
      status: status,
      onPressed: () {
        // Remove the overlay first (animate out) then navigate.
        _removeOverlay().then((_) {
          if (!isLocked) {
            final lessons = skillLevel.lessons;
            if (lessons == null || lessons.isEmpty) return;

            // Determine which lesson to open:
            // - If inProgress, open the user's current lesson position (convert to 0-based index)
            // - Otherwise open the first lesson
            int lessonIndex = 0;
            if (status == NodeStatus.inProgress) {
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

            // 1. Suck-in effect (Shrink the node)
            _controller.forward();
            Future.delayed(const Duration(milliseconds: 150), () {
              if (mounted) {
                // 2. Explode warp circle & Navigate
                _playWarpAnimation(context, lesson, popupBgColor, offset, renderBox.size);
              }
            });
          }
        });
      },
    );

    SpeechBubbleVariant bubbleVariant;
    switch (status) {
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


  void _playWarpAnimation(BuildContext context, dynamic lesson, Color color, Offset nodeOffset, Size nodeSize) async {
    final overlayState = Overlay.of(context);
    final screenSize = MediaQuery.of(context).size;
    final center = Offset(nodeOffset.dx + nodeSize.width / 2, nodeOffset.dy + nodeSize.height / 2);
    final maxRadius = math.sqrt(math.pow(screenSize.width, 2) + math.pow(screenSize.height, 2));

    final warpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    final scaleAnimation = Tween<double>(begin: 0.0, end: maxRadius).animate(
      CurvedAnimation(parent: warpController, curve: Curves.easeInCirc),
    );
    
    OverlayEntry? warpEntry;
    warpEntry = OverlayEntry(
      builder: (context) {
        return AnimatedBuilder(
          animation: scaleAnimation,
          builder: (context, child) {
            if (scaleAnimation.value <= 0.1) return const SizedBox.shrink();
            return Positioned(
              left: center.dx - scaleAnimation.value,
              top: center.dy - scaleAnimation.value,
              child: Container(
                width: scaleAnimation.value * 2,
                height: scaleAnimation.value * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
            );
          },
        );
      },
    );
    
    overlayState.insert(warpEntry);
    
    // 1. Vòng tròn lan tỏa kín màn hình
    await warpController.forward();
    
    // 2. Chuyển trang (nhưng không dùng await để block, cứ cho nó push)
    Navigator.pushNamed(
      context,
      '/exercise',
      arguments: {
        'lessonId': lesson.id,
        'lessonTitle': lesson.title,
        'isPronun': false,
      },
    );
    
    // 3. Đợi Route mới render ra bên dưới (tầm 100ms)
    await Future.delayed(const Duration(milliseconds: 100));

    // 4. Tạo Overlay mới full màn hình và mờ dần (Fade out) để lộ trang mới ra
    OverlayEntry? fadeEntry;
    fadeEntry = OverlayEntry(
      builder: (context) {
        return IgnorePointer(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.0, end: 0.0),
            duration: const Duration(milliseconds: 400),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Container(color: color),
              );
            },
          ),
        );
      },
    );
    overlayState.insert(fadeEntry);
    
    // Bỏ cái vòng tròn đặc đi để cái Fade mờ dần nó hiện ra
    warpEntry.remove();
    warpController.dispose();
    
    // Bounce the node back to normal in background
    if (mounted) {
      _controller.reverse();
    }
    
    // 5. Đợi fade xong thì xóa nốt Overlay fadeEntry
    await Future.delayed(const Duration(milliseconds: 450));
    fadeEntry.remove();
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.status;
    final double baseWidth = NodeTokens.baseWidth;
    final double baseHeight = baseWidth;
    final double shadowHeight = NodeTokens.shadowHeight;
    final double ringStrokeWidth = NodeTokens.ringStrokeWidth;
    final double ringGap = NodeTokens.ringGap;

    final double totalWidth = baseWidth;
    final double totalHeight = baseHeight + shadowHeight;

    double progress;
    if (status == NodeStatus.completed) {
      progress = 1.0;
    } else if (status == NodeStatus.inProgress) {
      // Calculate progress based on actual lesson completion
      // Use (lessonPosition - 1) / totalLessons so that:
      // - 1/5 = 0%
      // - 2/5 = 20%
      // - 5/5 = 80%
      final double total = widget.totalLessons > 0
          ? widget.totalLessons.toDouble()
          : 1.0;
      final double current = (widget.lessonPosition - 1).toDouble();
      progress = (current / total).clamp(0.0, 1.0);
    } else {
      progress = 0.0;
    }

    IconData iconData = _getIconForLevel(widget.skillLevel.description, widget.globalIndex);

    if (status == NodeStatus.legendary) {
      iconData = Icons.emoji_events;
    } else if (status == NodeStatus.completed) {
      // Completed node will keep the diverse icon, but we will make it shiny!
    } else if (status == NodeStatus.jumpAhead) {
      iconData = Icons.star;
    }

    Widget circleWidget = CustomPaint(
      size: Size(totalWidth, totalHeight),
      painter: EllipsePainter(
        offset: _offsetAnim.value,
        isReached: status != NodeStatus.locked,
        icon: iconData,
        iconSize: NodeTokens.iconSize,
        primaryColorOverride: (status == NodeStatus.legendary) ? AppColors.bee : widget.sectionColor,
        secondaryColorOverride: (status == NodeStatus.legendary) ? AppColors.fox : (widget.sectionShadowColor ?? widget.sectionColor),
        isCompleted: status == NodeStatus.completed || status == NodeStatus.legendary,
      ),
    );

    // Apply Shiny sweep effect for completed or legendary nodes
    if (status == NodeStatus.completed || status == NodeStatus.legendary) {
      circleWidget = ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) {
          return LinearGradient(
            begin: Alignment(-1.0 + _shinyAnimation.value, -1.0),
            end: Alignment(0.5 + _shinyAnimation.value, 1.0),
            stops: const [0.0, 0.4, 0.5, 0.6, 1.0],
            colors: [
              Colors.white.withValues(alpha: 0.0),
              Colors.white.withValues(alpha: 0.0),
              Colors.white.withValues(alpha: 0.8),
              Colors.white.withValues(alpha: 0.0),
              Colors.white.withValues(alpha: 0.0),
            ],
          ).createShader(bounds);
        },
        child: circleWidget,
      );
    }

    if (status == NodeStatus.inProgress || status == NodeStatus.jumpAhead) {
      final double nodeBoxSize = totalWidth > totalHeight
          ? totalWidth
          : totalHeight;
      final double ringSize = nodeBoxSize + (ringGap * 2) + ringStrokeWidth;

      final bool showTopOverlay =
          status == NodeStatus.inProgress || status == NodeStatus.jumpAhead;
      final double topOverlayExtra = showTopOverlay
          ? (NodeTokens.topOverlayHeight * NodeTokens.topOverlayExtraMultiplier)
          : 0.0;
      final double stackHeight = ringSize + topOverlayExtra;

      Widget ringAndNode = NodeVisual(
        ringSize: ringSize,
        ringStrokeWidth: ringStrokeWidth,
        progress: progress,
        progressColor: widget.sectionColor ?? AppColors.primary,
        nodeChild: circleWidget,
      );

      final String topOverlayText = status == NodeStatus.jumpAhead
          ? 'HỌC VƯỢT?'
          : 'BẮT ĐẦU';
      final double bubbleWidth = _estimateTopBubbleWidth(
        topOverlayText,
        context,
      );
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
          } else {
            _removeOverlay();
          }
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
        } else {
          _removeOverlay();
        }
      },
      child: circleWidget,
    );
  }

  IconData _getIconForLevel(String description, int index) {
    final lowerDesc = description.toLowerCase();
    if (lowerDesc.contains('nghe') || lowerDesc.contains('listen')) return Icons.headphones;
    if (lowerDesc.contains('nói') || lowerDesc.contains('phát âm') || lowerDesc.contains('speak')) return Icons.mic;
    if (lowerDesc.contains('đọc') || lowerDesc.contains('read')) return Icons.menu_book;
    if (lowerDesc.contains('từ vựng') || lowerDesc.contains('vocab')) return Icons.sort_by_alpha;
    if (lowerDesc.contains('ngữ pháp') || lowerDesc.contains('grammar')) return Icons.g_translate;
    if (lowerDesc.contains('chuyện') || lowerDesc.contains('story')) return Icons.auto_stories;

    // Default cyclic icons if no keyword matches
    const icons = [
      Icons.star,
      Icons.rocket_launch,
      Icons.local_fire_department,
      Icons.diamond,
      Icons.lightbulb,
      Icons.music_note,
    ];
    return icons[index % icons.length];
  }

  @override
  void dispose() {
    _controller.dispose();
    _topOverlayController.dispose();
    _topIdleController.dispose();
    _popupController.dispose();
    _shinyController.dispose();
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
    super.dispose();
  }
}
