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

class MultipleChoiceSimple extends StatefulWidget {
  final MultipleChoiceMetaEntity meta;
  final String exerciseId;
  final VoidCallback? onContinue;

  const MultipleChoiceSimple({
    super.key,
    required this.meta,
    required this.exerciseId,
    this.onContinue,
  });

  @override
  State<MultipleChoiceSimple> createState() => _MultipleChoiceSimpleState();
}

class _MultipleChoiceSimpleState extends State<MultipleChoiceSimple> with SingleTickerProviderStateMixin {
  int selectedOptionIndex = -1;
  bool _isSubmitted = false;
  bool _isLoading = false;

  late AnimationController _animationController;
  final List<Animation<double>> _slideAnimations = [];
  final List<Animation<double>> _fadeAnimations = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    for (int i = 0; i < widget.meta.options.length; i++) {
      final delay = i * 0.1;
      _slideAnimations.add(
        Tween<double>(begin: 50, end: 0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(delay, delay + 0.5, curve: Curves.easeOutCubic),
          ),
        ),
      );

      _fadeAnimations.add(
        Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(delay, delay + 0.5, curve: Curves.easeIn),
          ),
        ),
      );
    }

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleOptionSelectIndex(int index) {
    if (_isSubmitted) return;
    HapticFeedback.lightImpact();
    setState(() {
      if (selectedOptionIndex == index) {
        selectedOptionIndex = -1;
      } else {
        selectedOptionIndex = index;
      }
    });
  }

  void _handleSubmit() {
    if (selectedOptionIndex < 0) return;

    setState(() {
      _isSubmitted = true;
      _isLoading = true;
    });

    HapticFeedback.mediumImpact();

    final selectedOption = widget.meta.options[selectedOptionIndex];
    context.read<ExerciseBloc>().add(
      AnswerSelected(
        selectedAnswer: selectedOption.order.toString(),
        correctAnswer: widget.meta.correctOrder.first.toString(),
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
        selectedOptionIndex = -1;
        _isSubmitted = false;
        _isLoading = false;
      });
      _animationController.reset();
      _animationController.forward();
    }
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
                  challengeTitle: 'Chọn đáp án đúng',
                  challengeContent: Text(
                    widget.meta.question,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  characterPosition: CharacterPosition.left,
                  variant: isCorrect == null 
                      ? SpeechBubbleVariant.neutral 
                      : (isCorrect ? SpeechBubbleVariant.correct : SpeechBubbleVariant.incorrect),
                ),
              ),
            ),

            SizedBox(height: 32.h),

            // Options Grid
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Wrap(
                  spacing: 12.w,
                  runSpacing: 16.h,
                  alignment: WrapAlignment.center,
                  children: List.generate(widget.meta.options.length, (index) {
                    final option = widget.meta.options[index];
                    final isSelected = selectedOptionIndex == index;
                    final hasSelectedAny = selectedOptionIndex != -1;
                    final isCorrectOption = option.order == widget.meta.correctOrder.first;

                    bool? revealState;
                    if (_isSubmitted && isCorrect != null) {
                      if (isCorrectOption) {
                        revealState = true;
                      } else if (isSelected && !isCorrectOption) {
                        revealState = false;
                      }
                    }

                    return AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _slideAnimations[index].value),
                          child: Opacity(
                            opacity: _fadeAnimations[index].value,
                            child: child,
                          ),
                        );
                      },
                      child: _MechanicalOptionButton(
                        option: option,
                        isSelected: isSelected,
                        hasSelectedAny: hasSelectedAny,
                        revealState: revealState,
                        onTap: () => _handleOptionSelectIndex(index),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // Feedback or Action Button
            if (isCorrect != null && _isSubmitted)
              ExerciseFeedback(
                isCorrect: isCorrect,
                onContinue: _handleContinue,
                correctAnswer: isCorrect ? null : widget.meta.options.firstWhere(
                  (o) => o.order == widget.meta.correctOrder.first,
                  orElse: () => widget.meta.options.first,
                ).text,
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: AppButton(
                  label: 'KIỂM TRA',
                  onPressed: _handleSubmit,
                  isDisabled: selectedOptionIndex < 0 || _isSubmitted,
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

class _MechanicalOptionButton extends StatefulWidget {
  final MultipleChoiceOption option;
  final bool isSelected;
  final bool hasSelectedAny;
  final bool? revealState; // true = Correct (Green), false = Incorrect (Red), null = default
  final VoidCallback onTap;

  const _MechanicalOptionButton({
    required this.option,
    required this.isSelected,
    required this.hasSelectedAny,
    required this.revealState,
    required this.onTap,
  });

  @override
  State<_MechanicalOptionButton> createState() => _MechanicalOptionButtonState();
}

class _MechanicalOptionButtonState extends State<_MechanicalOptionButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
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
  void didUpdateWidget(_MechanicalOptionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger flip animation if it wasn't revealed before but now is
    if (oldWidget.revealState == null && widget.revealState != null) {
      _flipController.forward(from: 0);
    } else if (oldWidget.revealState != null && widget.revealState == null) {
      _flipController.reset();
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.revealState != null) return;
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.revealState != null) return;
    setState(() => _isPressed = false);
    widget.onTap();
  }

  void _handleTapCancel() {
    if (widget.revealState != null) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppPreferences().isDarkMode;
    
    // Dim other non-selected items to highlight the selected one
    final shouldDim = widget.hasSelectedAny && !widget.isSelected && widget.revealState == null;
    
    // The "Push" effect offset
    final double pushOffset = _isPressed ? 4.0 : (widget.isSelected ? 2.0 : 0.0);

    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final value = _flipAnimation.value;
        final angle = value * math.pi;
        final isFlipped = value >= 0.5;

        // Front Face
        Widget frontFace = AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          margin: EdgeInsets.only(top: pushOffset),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: widget.isSelected 
                ? (isDark ? AppColors.primary.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.1))
                : (isDark ? AppColors.swan : AppColors.snow),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: widget.isSelected ? AppColors.primary : AppColors.hare.withValues(alpha: 0.5),
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: [
              if (!_isPressed && !widget.isSelected)
                BoxShadow(
                  color: isDark ? Colors.black.withValues(alpha: 0.3) : AppColors.hare.withValues(alpha: 0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 0,
                )
              else if (widget.isSelected && !_isPressed)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  offset: const Offset(0, 2),
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
                    fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: widget.isSelected ? AppColors.primary : AppColors.eel,
                  ),
                ),
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
            margin: EdgeInsets.only(top: pushOffset),
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

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: shouldDim ? 0.4 : 1.0,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 300),
            scale: shouldDim ? 0.95 : 1.0,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              child: Transform(
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
              ),
            ),
          ),
        );
      },
    );
  }
}
