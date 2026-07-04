import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';

import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:vocabu_rex_mobile/theme/widgets/challenges/challenge.dart';
import 'package:vocabu_rex_mobile/theme/widgets/speech_bubbles/speech_bubble.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/exercise_feedback.dart';

class MultipleChoiceComplex extends StatefulWidget {
  final MultipleChoiceMetaEntity meta;
  final String exerciseId;
  final VoidCallback? onContinue;

  const MultipleChoiceComplex({
    super.key,
    required this.meta,
    required this.exerciseId,
    this.onContinue,
  });

  @override
  State<MultipleChoiceComplex> createState() => _MultipleChoiceComplexState();
}

class _MultipleChoiceComplexState extends State<MultipleChoiceComplex> {
  late List<MultipleChoiceOption> currentOrder;
  bool _isSubmitted = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo thứ tự lộn xộn ban đầu
    currentOrder = List.from(widget.meta.options)..shuffle();
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (_isSubmitted) return;
    HapticFeedback.lightImpact();
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = currentOrder.removeAt(oldIndex);
      currentOrder.insert(newIndex, item);
    });
  }

  void _handleSubmit() {
    setState(() {
      _isSubmitted = true;
      _isLoading = true;
    });

    HapticFeedback.mediumImpact();

    // In complex multiple choice, we need to send the arranged answer.
    // Assuming backend expects a specific format or order.
    // The previous implementation used selectedOrder mapping to IDs or similar.
    // We will join the order IDs or texts depending on backend expectation.
    // Let's check how AnswerSelected expects it.
    
    // To match backend logic, let's just join the ids or orders.
    // But actually, we only need to compare local correctness for UI, and bloc checks it too.
    String selectedAnswerString = currentOrder.map((e) => e.order.toString()).join(',');
    String correctAnswerString = widget.meta.correctOrder.map((e) => e.toString()).join(',');

    context.read<ExerciseBloc>().add(
      AnswerSelected(
        selectedAnswer: selectedAnswerString,
        correctAnswer: correctAnswerString,
        exerciseId: widget.exerciseId,
      ),
    );
  }

  void _handleContinue() {
    context.read<ExerciseBloc>().add(AnswerClear());
    if (widget.onContinue != null) {
      widget.onContinue!();
    } else {
      setState(() {
        _isSubmitted = false;
        _isLoading = false;
      });
    }
  }

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 12, animValue)!;
        final double scale = lerpDouble(1, 1.05, animValue)!;
        
        return Transform.scale(
          scale: scale,
          child: Material(
            elevation: elevation,
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16.r),
            shadowColor: Colors.black.withOpacity(0.5),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  double? lerpDouble(num? a, num? b, double t) {
    if (a == null && b == null) return null;
    a ??= 0.0;
    b ??= 0.0;
    return a + (b - a) * t;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExerciseBloc, ExerciseState>(
      listener: (context, state) {
        if (state is ExercisesLoaded && state.isCorrect != null) {
          if (state.isCorrect!) {
            HapticFeedback.heavyImpact();
          } else {
            HapticFeedback.vibrate();
          }
        }
      },
      builder: (context, state) {
        if (state is! ExercisesLoaded) return const SizedBox.shrink();

        final isCorrect = state.isCorrect;
        if (_isLoading && isCorrect != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _isLoading = false);
          });
        }

        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(height: 12.h),

            // Question Header
            FadeInDown(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: CharacterChallenge(
                  challengeTitle: 'Sắp xếp theo thứ tự',
                  challengeContent: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.meta.question,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '(Chạm giữ và kéo thả các ô bên dưới)',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                          color: AppColors.hare,
                        ),
                      ),
                    ],
                  ),
                  characterPosition: CharacterPosition.left,
                  variant: isCorrect == null 
                      ? SpeechBubbleVariant.neutral 
                      : (isCorrect ? SpeechBubbleVariant.correct : SpeechBubbleVariant.incorrect),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Reorderable List
            Expanded(
              child: Theme(
                // Hide default canvas color when dragging
                data: Theme.of(context).copyWith(
                  canvasColor: Colors.transparent,
                ),
                child: ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  itemCount: currentOrder.length,
                  proxyDecorator: _proxyDecorator,
                  onReorder: _onReorder,
                  itemBuilder: (context, index) {
                    final option = currentOrder[index];
                    
                    bool? revealState;
                    if (_isSubmitted && isCorrect != null) {
                      // Compare this block's order with the expected order at this index
                      if (index < widget.meta.correctOrder.length) {
                        final expectedOrderId = widget.meta.correctOrder[index];
                        revealState = (option.order == expectedOrderId);
                      } else {
                        // If there are more blocks than correct orders (interferences)
                        revealState = false;
                      }
                    }

                    return ReorderableDelayedDragStartListener(
                      key: ValueKey(option.order),
                      index: index,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _ReorderableLegoBlock(
                          option: option,
                          revealState: revealState,
                          isSubmitted: _isSubmitted,
                          index: index,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Feedback or Action Button
            if (isCorrect != null && _isSubmitted)
              ExerciseFeedback(
                isCorrect: isCorrect,
                onContinue: _handleContinue,
                correctAnswer: isCorrect ? null : widget.meta.correctOrder.map((id) {
                  return widget.meta.options.firstWhere(
                    (o) => o.order == id,
                    orElse: () => widget.meta.options.first,
                  ).text;
                }).join(' '),
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: AppButton(
                  label: 'KIỂM TRA',
                  onPressed: _handleSubmit,
                  isDisabled: _isSubmitted,
                  isLoading: _isLoading,
                  variant: ButtonVariant.primary,
                  size: ButtonSize.medium,
                  width: double.infinity,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ReorderableLegoBlock extends StatefulWidget {
  final MultipleChoiceOption option;
  final bool? revealState; // true = Correct (Green), false = Incorrect (Red), null = default
  final bool isSubmitted;
  final int index;

  const _ReorderableLegoBlock({
    required this.option,
    required this.revealState,
    required this.isSubmitted,
    required this.index,
  });

  @override
  State<_ReorderableLegoBlock> createState() => _ReorderableLegoBlockState();
}

class _ReorderableLegoBlockState extends State<_ReorderableLegoBlock> with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeOutBack),
    );
  }

  @override
  void didUpdateWidget(_ReorderableLegoBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.revealState == null && widget.revealState != null) {
      // Delay slightly for cascade effect
      Future.delayed(Duration(milliseconds: 100 * (widget.option.order % 5)), () {
        if (mounted) _flipController.forward(from: 0);
      });
    } else if (oldWidget.revealState != null && widget.revealState == null) {
      _flipController.reset();
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppPreferences().isDarkMode;

    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final value = _flipAnimation.value;
        final angle = value * math.pi;
        final isFlipped = value >= 0.5;

        // Front Face
        Widget frontFace = Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: isDark ? AppColors.swan : AppColors.snow,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.hare.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.3) : AppColors.hare.withValues(alpha: 0.3),
                offset: const Offset(0, 4),
                blurRadius: 0,
              )
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.option.text,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.eel,
                  ),
                ),
              ),
              if (!widget.isSubmitted)
                ReorderableDragStartListener(
                  index: widget.index,
                  child: Icon(Icons.drag_indicator_rounded, color: AppColors.wolf, size: 28.sp),
                ),
            ],
          ),
        );

        // Back Face (Result)
        Widget backFace = Container();
        if (widget.revealState != null) {
          final isCorrect = widget.revealState!;
          backFace = Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: isCorrect ? AppColors.featherGreen : AppColors.cardinal,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: isCorrect 
                      ? AppColors.maskGreen.withValues(alpha: 0.5) 
                      : Colors.red[900]!.withValues(alpha: 0.5),
                  offset: const Offset(0, 4),
                  blurRadius: 0,
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                  size: 28.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    widget.option.text,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(angle),
          child: isFlipped 
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateX(math.pi),
                  child: backFace,
                )
              : frontFace,
        );
      },
    );
  }
}
