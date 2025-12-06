import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:vocabu_rex_mobile/theme/widgets/word_tiles/app_match_tile.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/exercise_feedback.dart';

class MatchExercise extends StatefulWidget {
  final MatchMetaEntity meta;
  final String exerciseId;
  /// Callback invoked when the exercise requests to advance to the next
  /// exercise (e.g. when the user presses the continue button after checking).
  final VoidCallback? onContinue;
  const MatchExercise({
    super.key,
    required this.meta,
    required this.exerciseId,
    this.onContinue,
  });

  @override
  State<MatchExercise> createState() => _MatchExerciseState();
}

class _MatchExerciseState extends State<MatchExercise> {
  MatchMetaEntity get _meta => widget.meta;
  String get _exerciseId => widget.exerciseId;

  late List<String> leftItems;
  late List<String> rightItems;
  String? selectedLeft;
  String? selectedRight;
  Set<String> matchedLeft = {};
  Set<String> matchedRight = {};
  Set<String> correctLeft = {}; // Temporarily show as correct before disabling
  Set<String> correctRight = {}; // Temporarily show as correct before disabling
  Set<String> incorrectLeft = {}; // Temporarily show as incorrect
  Set<String> incorrectRight = {}; // Temporarily show as incorrect
  bool _revealed = false;

  FlutterTts flutterTts = FlutterTts();

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.3);
    await flutterTts.speak(text);
  }

  @override
  void initState() {
    super.initState();
    leftItems = _meta.pairs.map((p) => p.left).toList();
    rightItems = _meta.pairs.map((p) => p.right).toList()..shuffle();
  }

  void handleSelection(String item, bool isLeft) {
    setState(() {
      if (isLeft) {
        if (selectedLeft == item) {
          selectedLeft = null;
        } else {
          selectedLeft = item;
          _playPause(item);
        }
      } else {
        if (selectedRight == item) {
          selectedRight = null;
        } else {
          selectedRight = item;
        }
      }

      if (selectedLeft != null && selectedRight != null) {
        // kiểm tra đúng/sai
        final correctPair = widget.meta.pairs.firstWhere(
          (p) => p.left == selectedLeft && p.right == selectedRight,
          orElse: () => MatchPair(left: '', right: ''),
        );

        if (correctPair.left.isNotEmpty) {
          // đúng - show correct animation then transition to disabled
          final left = selectedLeft!;
          final right = selectedRight!;
          
          correctLeft.add(left);
          correctRight.add(right);
          
          // After animation, transition to disabled state
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              setState(() {
                correctLeft.remove(left);
                correctRight.remove(right);
                matchedLeft.add(left);
                matchedRight.add(right);
              });
            }
          });
        } else {
          // sai - show incorrect animation then reset
          final left = selectedLeft!;
          final right = selectedRight!;
          
          incorrectLeft.add(left);
          incorrectRight.add(right);
          
          // After shake animation, remove incorrect state
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) {
              setState(() {
                incorrectLeft.remove(left);
                incorrectRight.remove(right);
              });
            }
          });
        }

        // reset chọn
        selectedLeft = null;
        selectedRight = null;

        //nếu nối hết -> gửi sự kiện kết thúc
        if (matchedLeft.length + correctLeft.length == leftItems.length) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) {
              context.read<ExerciseBloc>().add(
                AnswerSelected(
                  selectedAnswer: "done",
                  correctAnswer: "done",
                  exerciseId: _exerciseId,
                ),
              );
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseBloc, ExerciseState>(
      builder: (context, state) {
        if (state is ExercisesLoaded) {
          return Column(
            // allow this exercise to expand and fill the vertical space
            // provided by the parent so its height matches other exercises
            mainAxisSize: MainAxisSize.max,
            children: [
                // reduced top spacing to sit closer to the page header
                SizedBox(height: 12.h),
                // Header section (match screenshot)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Text(
                      'Nhấn vào các cặp tương ứng',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppColors.eel,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                // Responsive area for tiles. Use Expanded so the tile area fills
                // the available vertical space between the header and the
                // action buttons; parent (`ExercisePage`) already constrains the
                // AnimatedSwitcher with an Expanded, so this is safe.
                Expanded(
                  child: LayoutBuilder(builder: (context, constraints) {
                    // Number of rows we need to fit vertically (max of columns)
                    final maxRows = max(leftItems.length, rightItems.length);
                    // reserve some vertical space for header and buttons
                    final reservedVertical = 0.h;
                    final availableHeight = max(0.0, constraints.maxHeight - reservedVertical);

                    // Determine tile height so every tile in the column shares the same height
                    final tileByHeight = maxRows > 0 ? (availableHeight / maxRows) : 140.h;
                    // clamp to a sensible minimum/maximum so tiles remain usable
                    final minTileH = 48.h;
                    final maxTileH = 180.h;
                    double tileHeight = tileByHeight.clamp(minTileH, maxTileH);
                    
                    // Calculate equal width for both columns (40% of screen width each)
                    final columnWidth = MediaQuery.of(context).size.width * 0.40;

                    return SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left column
                          SizedBox(
                            width: columnWidth,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: leftItems.map((item) {
                                final isMatched = matchedLeft.contains(item);
                                final isCorrect = correctLeft.contains(item);
                                final isIncorrect = incorrectLeft.contains(item);
                                final isSelected = selectedLeft == item;
                                final state = _revealed
                                    ? MatchTileState.disabled
                                    : isMatched
                                        ? MatchTileState.disabled
                                        : isCorrect
                                            ? MatchTileState.correct
                                            : isIncorrect
                                                ? MatchTileState.incorrect
                                                : isSelected
                                                    ? MatchTileState.selected
                                                    : MatchTileState.defaults;
                                // Cột trái hiển thị icon âm thanh
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4.h),
                                  child: MatchTile(
                                    word: item,
                                    state: state,
                                    height: tileHeight,
                                    showSoundIcon: true,
                                    onPressed: (isMatched || isCorrect || isIncorrect) ? null : () => handleSelection(item, true),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          SizedBox(width: 16.w),

                          // Right column
                          SizedBox(
                            width: columnWidth,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: rightItems.map((item) {
                                final isMatched = matchedRight.contains(item);
                                final isCorrect = correctRight.contains(item);
                                final isIncorrect = incorrectRight.contains(item);
                                final isSelected = selectedRight == item;
                                final state = _revealed
                                    ? MatchTileState.disabled
                                    : isMatched
                                        ? MatchTileState.disabled
                                        : isCorrect
                                            ? MatchTileState.correct
                                            : isIncorrect
                                                ? MatchTileState.incorrect
                                                : isSelected
                                                    ? MatchTileState.selected
                                                    : MatchTileState.defaults;
                                // Cột phải hiển thị text
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4.h),
                                  child: MatchTile(
                                    word: item,
                                    state: state,
                                    height: tileHeight,
                                    showSoundIcon: false,
                                    onPressed: (isMatched || isCorrect || isIncorrect) ? null : () => handleSelection(item, false),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                // make a larger spacer so buttons sit closer to the bottom like the screenshot
                SizedBox(height: 40.h),
                // Action buttons area. When the bloc reports a result (isCorrect != null)
                // we show the result in the same area (colored background) and a
                // continue button that calls the optional onContinue callback and
                // clears the answer. Otherwise show the regular two buttons.
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: BlocBuilder<ExerciseBloc, ExerciseState>(builder: (ctx, bState) {
                    final hasInteraction = matchedLeft.isNotEmpty || matchedRight.isNotEmpty || selectedLeft != null || selectedRight != null;
                    final isCorrect = (bState is ExercisesLoaded) ? bState.isCorrect : null;

                    if (isCorrect != null) {
                      return ExerciseFeedback(
                        isCorrect: isCorrect,
                        onContinue: () {
                          ctx.read<ExerciseBloc>().add(AnswerClear());
                          if (widget.onContinue != null) widget.onContinue!();
                        },
                        correctAnswer: null, // Match exercise doesn't show answer text
                        hint: _revealed ? 'Bạn đã xem gợi ý!' : null,
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppButton(
                          label: "HIỆN KHÔNG NGHE ĐƯỢC".toUpperCase(),
                          onPressed: () {
                            setState(() {
                              _revealed = true;
                              matchedLeft = leftItems.toSet();
                              matchedRight = rightItems.toSet();
                            });
                          },
                          isDisabled: !hasInteraction,
                          variant: ButtonVariant.outline,
                          size: ButtonSize.medium,
                        ),
                        SizedBox(height: 12.h),
                        AppButton(
                          label: "KIỂM TRA".toUpperCase(),
                          onPressed: () {
                            if (matchedLeft.length == leftItems.length) {
                              ctx.read<ExerciseBloc>().add(
                                AnswerSelected(
                                  selectedAnswer: "done",
                                  correctAnswer: "done",
                                  exerciseId: _exerciseId,
                                ),
                              );
                            } else {
                              ctx.read<ExerciseBloc>().add(
                                AnswerSelected(
                                  selectedAnswer: matchedLeft.join(','),
                                  correctAnswer: matchedRight.join(','),
                                  exerciseId: _exerciseId,
                                ),
                              );
                            }
                          },
                          isDisabled: matchedLeft.length != leftItems.length,
                          variant: ButtonVariant.primary,
                          size: ButtonSize.medium,
                        ),
                      ],
                    );
                  }),
                ),
              ],
            );
        }
        return SizedBox.shrink();
      },
    );
  }

  void _playPause(String word) async {
    if (word.isNotEmpty) {
      await speak(word);
    }
  }
}
