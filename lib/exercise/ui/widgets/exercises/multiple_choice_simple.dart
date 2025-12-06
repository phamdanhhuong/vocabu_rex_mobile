import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/widgets/word_tiles/app_choice_tile.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:vocabu_rex_mobile/theme/widgets/challenges/challenge.dart';
import 'package:vocabu_rex_mobile/theme/widgets/speech_bubbles/speech_bubble.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/exercise_feedback.dart';

/// Simple multiple choice UI - when correctOrder.length == 1
/// Displays options as clickable tiles in a grid layout
class MultipleChoiceSimple extends StatefulWidget {
  final MultipleChoiceMetaEntity meta;
  final String exerciseId;
  final VoidCallback? onContinue;
  
  const MultipleChoiceSimple({
    Key? key,
    required this.meta,
    required this.exerciseId,
    this.onContinue,
  }) : super(key: key);

  @override
  State<MultipleChoiceSimple> createState() => _MultipleChoiceSimpleState();
}

class _MultipleChoiceSimpleState extends State<MultipleChoiceSimple>
    with SingleTickerProviderStateMixin {
  // Use index-based selection (like ListenChoose) to avoid object equality bugs
  int selectedOptionIndex = -1; // -1 means none selected
  bool _isSubmitted = false;
  
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
    
    // Create staggered animations for each option
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
    setState(() {
      // Toggle selection like ListenChoose: select by index, deselect if tapping same
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
    });

    final chosen = widget.meta.options[selectedOptionIndex];
    context.read<ExerciseBloc>().add(
      AnswerSelected(
        selectedAnswer: chosen.text,
        correctAnswer: widget.meta.options
            .firstWhere((o) => o.order == widget.meta.correctOrder[0])
            .text,
        exerciseId: widget.exerciseId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseBloc, ExerciseState>(
      builder: (context, state) {
        if (state is! ExercisesLoaded) {
          return const SizedBox.shrink();
        }

        final isCorrect = state.isCorrect;
        
        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(height: 12.h),
            
            // Challenge with character
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: CharacterChallenge(
                challengeTitle: 'Chọn đáp án đúng',
                challengeContent: Text(
                  widget.meta.question,
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                ),
                character: Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: Colors.green[300],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.quiz, size: 40.sp, color: Colors.white),
                ),
                characterPosition: CharacterPosition.left,
                variant: isCorrect == null
                    ? SpeechBubbleVariant.neutral
                    : (isCorrect ? SpeechBubbleVariant.correct : SpeechBubbleVariant.incorrect),
              ),
            ),
            
            SizedBox(height: 20.h),
            
            // Options grid
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                itemCount: widget.meta.options.length,
                itemBuilder: (context, index) {
                  final option = widget.meta.options[index];
                  
                  ChoiceTileState tileState = ChoiceTileState.defaults;

                  // Explicit logic: only the single selectedOption should be shown as selected
                  // before submission; after submission we only color the correct answer
                  // and the user's chosen answer (if it was wrong).
                  if (isCorrect != null) {
                    // After submission: mark the correct answer first
                    if (option.order == widget.meta.correctOrder[0]) {
                      tileState = ChoiceTileState.correct;
                    } else if (selectedOptionIndex >= 0 && index == selectedOptionIndex) {
                      // If the user selected this (and it's not the correct answer), mark incorrect
                      tileState = ChoiceTileState.incorrect;
                    }
                  } else {
                    // Before submission: only the actively selected option shows selected style
                    if (selectedOptionIndex >= 0 && index == selectedOptionIndex) {
                      tileState = ChoiceTileState.selected;
                    }
                  }
                  
                  return AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _slideAnimations[index].value),
                        child: Opacity(
                          opacity: _fadeAnimations[index].value,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.h),
                            child: ChoiceTile(
                              text: option.text,
                              state: tileState,
                              onPressed: isCorrect == null 
                                  ? () => _handleOptionSelectIndex(index)
                                  : () {},
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            
            SizedBox(height: 12.h),
            
            // Action buttons
            if (isCorrect != null)
              ExerciseFeedback(
                isCorrect: isCorrect,
                onContinue: () {
                  context.read<ExerciseBloc>().add(AnswerClear());
                  if (widget.onContinue != null) {
                    widget.onContinue!();
                  } else {
                    setState(() {
                      selectedOptionIndex = -1;
                      _isSubmitted = false;
                    });
                  }
                },
                correctAnswer: isCorrect
                    ? null
                    : widget.meta.options
                        .firstWhere((o) => o.order == widget.meta.correctOrder[0])
                        .text,
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: AppButton(
                  label: 'KIỂM TRA',
                  onPressed: _handleSubmit,
                  isDisabled: selectedOptionIndex < 0,
                  variant: ButtonVariant.primary,
                  size: ButtonSize.medium,
                ),
              ),
          ],
        );
      },
    );
  }
}
