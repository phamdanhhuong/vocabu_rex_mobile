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

class _CompareWordsState extends State<CompareWords>
    with TickerProviderStateMixin {
  FlutterTts flutterTts = FlutterTts();
  bool? selectedAnswer; // true = same, false = different, null = not selected
  bool _isSubmitted = false;
  bool _isSpeaking = false;
  String? _currentSpeakingWord;

  late AnimationController _animationController1;
  late AnimationController _animationController2;
  late Animation<double> _scaleAnimation1;
  late Animation<double> _scaleAnimation2;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController1 = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animationController2 = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation1 = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController1, curve: Curves.easeInOut),
    );
    _scaleAnimation2 = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController2, curve: Curves.easeInOut),
    );
  }

  void _initTts() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(0.8);
    await flutterTts.setPitch(1.0);

    flutterTts.setStartHandler(() {
      setState(() {
        _isSpeaking = true;
      });
    });

    flutterTts.setCompletionHandler(() {
      final wasWord1Speaking = _currentSpeakingWord == widget.meta.word1;
      final wasWord2Speaking = _currentSpeakingWord == widget.meta.word2;

      setState(() {
        _isSpeaking = false;
        _currentSpeakingWord = null;
      });

      // Only reverse the animation that was active
      if (wasWord1Speaking) {
        _animationController1.reverse();
      } else if (wasWord2Speaking) {
        _animationController2.reverse();
      }
    });

    flutterTts.setErrorHandler((msg) {
      final wasWord1Speaking = _currentSpeakingWord == widget.meta.word1;
      final wasWord2Speaking = _currentSpeakingWord == widget.meta.word2;

      setState(() {
        _isSpeaking = false;
        _currentSpeakingWord = null;
      });

      // Only reverse the animation that was active
      if (wasWord1Speaking) {
        _animationController1.reverse();
      } else if (wasWord2Speaking) {
        _animationController2.reverse();
      }
    });
  }

  void _speakWord(String word) async {
    // If already speaking this word, stop it
    if (_isSpeaking && _currentSpeakingWord == word) {
      await flutterTts.stop();
      return;
    }

    // If speaking different word, stop current and start new
    if (_isSpeaking) {
      await flutterTts.stop();
    }

    // Reset all states first
    setState(() {
      _isSpeaking = false;
      _currentSpeakingWord = null;
    });

    // Reset all animations
    await _animationController1.reverse();
    await _animationController2.reverse();

    // Set new speaking word
    setState(() {
      _currentSpeakingWord = word;
    });

    // Start animation for the correct button
    if (word == widget.meta.word1) {
      _animationController1.forward();
    } else {
      _animationController2.forward();
    }

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
    _animationController1.dispose();
    _animationController2.dispose();
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
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
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

            SizedBox(height: 12.h),

            // Action buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: isCorrect == null
                  ? AppButton(
                      label: 'KIỂM TRA',
                      onPressed: _handleSubmit,
                      isDisabled: selectedAnswer == null,
                      variant: ButtonVariant.primary,
                      size: ButtonSize.medium,
                      width: double.infinity,
                    )
                  : AppButton(
                      label: 'TIẾP TỤC',
                      onPressed: () {
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
    final isCurrentlySpeaking = _currentSpeakingWord == word;
    final isWord1 = number == 1;
    final animation = isWord1 ? _scaleAnimation1 : _scaleAnimation2;
    final controller = isWord1 ? _animationController1 : _animationController2;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: GestureDetector(
            onTapDown: (_) {
              // Only allow press animation if this button is not currently selected
              if (_currentSpeakingWord != word) {
                controller.forward();
              }
            },
            onTapUp: (_) {
              // Always reverse press animation on tap up if not selected
              if (_currentSpeakingWord != word) {
                controller.reverse();
              }
              _speakWord(word);
            },
            onTapCancel: () {
              // Reverse press animation on cancel if not selected
              if (_currentSpeakingWord != word) {
                controller.reverse();
              }
            },
            child: Container(
              width: 140.w,
              height: 100.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background layer with shadow
                  Container(
                    width: 140.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      color: isCurrentlySpeaking
                          ? AppColors.selectionBlueLight
                          : AppColors.snow,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isCurrentlySpeaking
                            ? AppColors.selectionBlueDark
                            : AppColors.swan,
                        width: 2.0,
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
          ),
        );
      },
    );
  }

  Widget _buildSoundIcon(bool isCurrentlySpeaking) {
    // Also check _isSpeaking for sound wave animation
    final showActiveState = isCurrentlySpeaking && _isSpeaking;

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
                height: showActiveState ? _getSoundWaveHeight(index) : 8.h,
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
