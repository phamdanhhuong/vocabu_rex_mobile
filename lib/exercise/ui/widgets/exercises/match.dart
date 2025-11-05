import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:vocabu_rex_mobile/theme/widgets/word_tiles/app_word_tile.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';

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
          // đúng
          matchedLeft.add(selectedLeft!);
          matchedRight.add(selectedRight!);
        }

        // reset chọn
        selectedLeft = null;
        selectedRight = null;

        //nếu nối hết -> gửi sự kiện kết thúc
        if (matchedLeft.length == leftItems.length) {
          context.read<ExerciseBloc>().add(
            AnswerSelected(
              selectedAnswer: "done",
              correctAnswer: "done",
              exerciseId: _exerciseId,
            ),
          );
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
                        color: AppColors.humpback,
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
                    final reservedVertical = 0.h; // approximate header + buttons + paddings
                    final availableHeight = max(0.0, constraints.maxHeight - reservedVertical);

                    // Determine tile height so every tile in the column shares the
                    // same height. Width is left unconstrained so each tile can
                    // expand to fit its text completely.
                    final tileByHeight = maxRows > 0 ? (availableHeight / maxRows) : 140.h;
                    // clamp to a sensible minimum/maximum so tiles remain usable
                    final minTileH = 48.h;
                    final maxTileH = 180.h;
                    double tileHeight = tileByHeight.clamp(minTileH, maxTileH);

                    // horizontal gap between the two columns
                    final spacingBetween = 0.w;

                    // Explicit tile width: use 40% of the available width
                    // (constraints.maxWidth is the full width available to this
                    // LayoutBuilder). This gives each tile a consistent width
                    // across both columns.
                      // Use full device screen width (MediaQuery) to calculate the
                      // requested tile width percentage rather than the local
                      // LayoutBuilder constraints. This makes the tile width a
                      // consistent fraction of the screen width.
                      final requestedTileWidth = MediaQuery.of(context).size.width * 0.25;
                    // Ensure two tiles + spacing fit into available width. If not,
                    // reduce to half of (available - spacing). Also clamp to a
                    // sensible minimum so tiles stay tappable.
                    final availForTwo = max(0.0, constraints.maxWidth - spacingBetween);
                    final maxPerColumn = availForTwo / 2.0;
                    final explicitTileWidth = requestedTileWidth.clamp(64.w, maxPerColumn);

                    return SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left column
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: leftItems.map((item) {
                              final isMatched = matchedLeft.contains(item) || _revealed;
                              final isSelected = selectedLeft == item;
                              final state = isMatched
                                  ? WordTileState.correct
                                  : isSelected
                                      ? WordTileState.selected
                                      : WordTileState.defaults;
                              // tiles use a uniform height; width will expand to fit text
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.h),
                                child: SizedBox(
                                  width: explicitTileWidth,
                                  child: WordTile(
                                    word: item,
                                    state: state,
                                    size: tileHeight,
                                    width: explicitTileWidth,
                                    onPressed: isMatched ? () {} : () => handleSelection(item, true),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          SizedBox(width: spacingBetween),

                          // Right column
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: rightItems.map((item) {
                              final isMatched = matchedRight.contains(item) || _revealed;
                              final isSelected = selectedRight == item;
                              final state = isMatched
                                  ? WordTileState.correct
                                  : isSelected
                                      ? WordTileState.selected
                                      : WordTileState.defaults;
                              // tiles use a uniform height; width will expand to fit text
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.h),
                                child: SizedBox(
                                  width: explicitTileWidth,
                                  child: WordTile(
                                    word: item,
                                    state: state,
                                    size: tileHeight,
                                    width: explicitTileWidth,
                                    onPressed: isMatched ? () {} : () => handleSelection(item, false),
                                  ),
                                ),
                              );
                            }).toList(),
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
                      return Container(
                        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: isCorrect ? AppColors.correctGreenLight : AppColors.incorrectRedLight,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              isCorrect ? 'Chính xác !!!' : 'Sai rồi !!!',
                              style: TextStyle(
                                color: isCorrect ? AppColors.primary : AppColors.cardinal,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            AppButton(
                              label: 'Tiếp tục',
                              onPressed: () {
                                // Clear the answer and advance if parent provided onContinue
                                ctx.read<ExerciseBloc>().add(AnswerClear());
                                if (widget.onContinue != null) widget.onContinue!();
                              },
                              variant: ButtonVariant.primary,
                              size: ButtonSize.medium,
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppButton(
                          label: "HIỆN KHÔNG NGHE ĐƯỢC".toUpperCase(),
                          onPressed: hasInteraction
                              ? () {
                                  setState(() {
                                    _revealed = true;
                                    matchedLeft = leftItems.toSet();
                                    matchedRight = rightItems.toSet();
                                  });
                                }
                              : null,
                          variant: ButtonVariant.outline,
                          size: ButtonSize.medium,
                        ),
                        SizedBox(height: 12.h),
                        AppButton(
                          label: "KIỂM TRA".toUpperCase(),
                          onPressed: hasInteraction
                              ? () {
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
                                }
                              : null,
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
