import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:vocabu_rex_mobile/theme/widgets/challenges/challenge.dart';
import 'package:vocabu_rex_mobile/theme/widgets/speech_bubbles/speech_bubble.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/exercise_feedback.dart';
import 'package:vocabu_rex_mobile/theme/widgets/word_tiles/app_word_tile.dart';

/// Compare Words Exercise - Compare pronunciation of two words
class CompareWords extends StatefulWidget {
  final CompareWordsMetaEntity meta;
  final String exerciseId;
  final VoidCallback? onContinue;

  const CompareWords({
    Key? key,
    required this.meta,
    required this.exerciseId,
    this.onContinue,
  }) : super(key: key);

  @override
  State<CompareWords> createState() => _CompareWordsState();
}

class _CompareWordsState extends State<CompareWords> {
  FlutterTts flutterTts = FlutterTts();
  bool? selectedAnswer; // true = same, false = different, null = not selected
  bool _isSubmitted = false;
  bool _isWord1Speaking = false;
  bool _isWord2Speaking = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(0.8);
    await flutterTts.setPitch(1.0);

    flutterTts.setCompletionHandler(() {
      setState(() {
        _isWord1Speaking = false;
        _isWord2Speaking = false;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        _isWord1Speaking = false;
        _isWord2Speaking = false;
      });
    });
  }

  void _speakWord(String word, int number) async {
    // If already speaking this word, stop it
    if ((number == 1 && _isWord1Speaking) || (number == 2 && _isWord2Speaking)) {
      await flutterTts.stop();
      setState(() {
        if (number == 1) _isWord1Speaking = false;
        if (number == 2) _isWord2Speaking = false;
      });
      return;
    }

    // Stop any current speech
    await flutterTts.stop();
    
    // Reset both states
    setState(() {
      _isWord1Speaking = false;
      _isWord2Speaking = false;
    });

    // Set the speaking state for the current word
    setState(() {
      if (number == 1) {
        _isWord1Speaking = true;
      } else if (number == 2) {
        _isWord2Speaking = true;
      }
    });

    // Start speaking
    await flutterTts.speak(word);
  }

  void _handleAnswerSelect(bool answer) {
    if (_isSubmitted) return;
    setState(() {
      selectedAnswer = answer;
    });
  }

  void _handleSubmit() {
    if (selectedAnswer == null) return;

    setState(() {
      _isSubmitted = true;
    });

    context.read<ExerciseBloc>().add(
      AnswerSelected(
        selectedAnswer: selectedAnswer! ? 'same' : 'different',
        correctAnswer: widget.meta.correctAnswer ? 'same' : 'different',
        exerciseId: widget.exerciseId,
      ),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
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
                challengeTitle: 'So sánh phát âm',
                challengeContent: Text(
                  widget.meta.instruction,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                character: Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: const BoxDecoration(
                    color: AppColors.macaw,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.headset,
                    size: 40.sp,
                    color: AppColors.white,
                  ),
                ),
                characterPosition: CharacterPosition.left,
                variant: isCorrect == null
                    ? SpeechBubbleVariant.neutral
                    : (isCorrect
                          ? SpeechBubbleVariant.correct
                          : SpeechBubbleVariant.incorrect),
              ),
            ),

            SizedBox(height: 30.h),

            // Word pronunciation buttons
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    // Word 1
                    Center(child: _buildWordButton(widget.meta.word1, 1)),
                    SizedBox(height: 20.h),

                    // VS divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: AppColors.swan, thickness: 1),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            'VS',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.eel,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: AppColors.swan, thickness: 1),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // Word 2
                    Center(child: _buildWordButton(widget.meta.word2, 2)),

                    SizedBox(height: 40.h),

                    // Answer options
                    Text(
                      'Hai từ này có phát âm giống nhau không?',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.eel,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 20.h),

                    // Same/Different buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildAnswerButton(
                            'GIỐNG NHAU',
                            true,
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildAnswerButton(
                            'KHÁC NHAU',
                            false,
                            Icons.close,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    // Explanation (after submission)
                    if (_isSubmitted && widget.meta.explanation != null) ...[
                      SizedBox(height: 20.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.snow,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.swan),
                        ),
                        child: Text(
                          widget.meta.explanation!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.eel,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    ],
                  ),
                ),
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
                      selectedAnswer = null;
                      _isSubmitted = false;
                    });
                  }
                },
                correctAnswer: null,
                hint: widget.meta.correctAnswer
                    ? 'Hai từ này phát âm giống nhau'
                    : 'Hai từ này phát âm khác nhau',
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: AppButton(
                  label: 'KIỂM TRA',
                  onPressed: _handleSubmit,
                  isDisabled: selectedAnswer == null,
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

  Widget _buildWordButton(String word, int number) {
    final isCurrentlySpeaking = number == 1 ? _isWord1Speaking : _isWord2Speaking;
    
    // Use WordTile styling but with custom content
    return GestureDetector(
      onTap: () => _speakWord(word, number),
      child: Container(
        width: 140.w,
        height: 64.h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background layer with shadow (WordTile style)
            Container(
              height: 60.h,
              decoration: BoxDecoration(
                color: isCurrentlySpeaking
                    ? AppColors.selectionBlueLight
                    : AppColors.snow,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isCurrentlySpeaking
                      ? AppColors.macaw
                      : AppColors.swan,
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isCurrentlySpeaking
                        ? AppColors.selectionBlueDark
                        : AppColors.hare,
                    blurRadius: 0,
                    offset: Offset(0, 4.h),
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
            // Content layer
            Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: _buildSoundIcon(isCurrentlySpeaking),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundIcon(bool isCurrentlySpeaking) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.volume_up,
          color: isCurrentlySpeaking ? AppColors.macaw : AppColors.eel,
          size: 24.sp,
        ),
        SizedBox(width: 8.w),
        // Sound waves animation
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(5, (index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.w),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300 + index * 100),
                width: 3.w,
                height: isCurrentlySpeaking ? _getSoundWaveHeight(index) : 8.h,
                decoration: BoxDecoration(
                  color: isCurrentlySpeaking ? AppColors.macaw : AppColors.eel,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  double _getSoundWaveHeight(int index) {
    final heights = [12.h, 18.h, 24.h, 18.h, 12.h];
    return heights[index];
  }

  Widget _buildAnswerButton(
    String text,
    bool value,
    IconData icon,
    Color color,
  ) {
    bool isSelected = selectedAnswer == value;
    bool isCorrectAnswer = widget.meta.correctAnswer == value;
    bool isIncorrect = _isSubmitted && isSelected && !isCorrectAnswer;
    bool isShowingCorrect = _isSubmitted && isCorrectAnswer;

    ButtonVariant variant = ButtonVariant.outline;
    Color? backgroundColor;

    if (_isSubmitted) {
      if (isShowingCorrect) {
        variant = ButtonVariant.primary;
        backgroundColor = AppColors.correctGreenDark;
      } else if (isIncorrect) {
        variant = ButtonVariant.primary;
        backgroundColor = AppColors.incorrectRedDark;
      }
    } else if (isSelected) {
      variant = ButtonVariant.primary;
      backgroundColor = AppColors.selectionBlueDark;
    }

    return AppButton(
      label: text,
      onPressed: _isSubmitted ? () {} : () => _handleAnswerSelect(value),
      variant: variant,
      size: ButtonSize.medium,
      backgroundColor: backgroundColor,
      isDisabled: _isSubmitted,
    );
  }
}
