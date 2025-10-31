import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/custom_button.dart';
import 'package:vocabu_rex_mobile/theme/widgets/word_tiles/app_word_tile.dart';
import 'package:vocabu_rex_mobile/theme/widgets/word_tiles/app_word_tile_tokens.dart';
import 'package:vocabu_rex_mobile/theme/widgets/challenges/challenge.dart';
import 'package:vocabu_rex_mobile/theme/widgets/speech_bubbles/speech_bubble.dart';

class MultipleChoice extends StatefulWidget {
  final MultipleChoiceMetaEntity meta;
  final String exerciseId;
  const MultipleChoice({
    super.key,
    required this.meta,
    required this.exerciseId,
  });

  @override
  State<MultipleChoice> createState() => _MultipleChoiceState();
}

class _MultipleChoiceState extends State<MultipleChoice>
  with TickerProviderStateMixin {
  MultipleChoiceMetaEntity get _meta => widget.meta;
  String get _exerciseId => widget.exerciseId;

  List<MultipleChoiceOption> selectedOrder = [];
  List<MultipleChoiceOption> shuffledOptions = [];
  // displayed slot contents used for staggered animations
  late List<MultipleChoiceOption?> _displayedSelectedSlots;
  late List<MultipleChoiceOption?> _displayedOptionSlots;
  // keys used to locate widgets on screen for animation
  // (per-option keys removed; we use per-slot keys instead)
  final Map<int, GlobalKey> _selectedSlotKeys = {};
  final Map<int, GlobalKey> _optionSlotKeys = {};
  final GlobalKey _selectedAreaKey = GlobalKey();
  final GlobalKey _optionsAreaKey = GlobalKey();
  final Duration _flyDuration = const Duration(milliseconds: 520);
  final Set<int> _animating = {};

  @override
  void initState() {
    shuffledOptions = List<MultipleChoiceOption>.from(_meta.options)..shuffle();
    // initialize displayed slots with current data
    _displayedSelectedSlots = List<MultipleChoiceOption?>.filled(_meta.options.length, null);
    for (int i = 0; i < selectedOrder.length && i < _displayedSelectedSlots.length; i++) {
      _displayedSelectedSlots[i] = selectedOrder[i];
    }

    _displayedOptionSlots = List<MultipleChoiceOption?>.filled(_meta.options.length, null);
    for (int i = 0; i < shuffledOptions.length && i < _displayedOptionSlots.length; i++) {
      _displayedOptionSlots[i] = shuffledOptions[i];
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void handleSubmit() {
    List<int> order = selectedOrder.map((option) {
      return option.order;
    }).toList();
    bool isCorrect = true;

    if (order.length == _meta.correctOrder.length) {
      for (int i = 0; i < order.length; i++) {
        if (order[i] != _meta.correctOrder[i]) {
          isCorrect = false;
        }
      }
    } else {
      isCorrect = false;
    }

    context.read<ExerciseBloc>().add(
      AnswerSelected(
        selectedAnswer: isCorrect ? "done" : "",
        correctAnswer: "done",
        exerciseId: _exerciseId,
      ),
    );
  }

  

  

  Future<void> _onSelectOption(MultipleChoiceOption option) async {
    // mark animating immediately so the source tile hides
    // compute desired displayedSelected target index first (first empty)
    final newDisplayedSelected = List<MultipleChoiceOption?>.from(_displayedSelectedSlots);
    final targetIndex = newDisplayedSelected.indexWhere((e) => e == null);
    final int insertIndex = targetIndex == -1 ? newDisplayedSelected.length - 1 : targetIndex;

    setState(() {
      _animating.add(option.order);
    });
    await _animateTileMove(option, toSelected: true, targetIndex: insertIndex);

    // compute desired displayed slot arrays after the move
    // we already computed insertIndex before animating; recompute here for safety
    final newDisplayedSelected2 = List<MultipleChoiceOption?>.from(_displayedSelectedSlots);
    final targetIndex2 = newDisplayedSelected2.indexWhere((e) => e == null);
    final int insertIndex2 = targetIndex2 == -1 ? newDisplayedSelected2.length - 1 : targetIndex2;
    if (insertIndex2 >= 0 && insertIndex2 < newDisplayedSelected2.length) {
      newDisplayedSelected2[insertIndex2] = option;
    }

  final newDisplayedOptions = List<MultipleChoiceOption?>.from(_displayedOptionSlots);
    // remove the option from option slots
    for (int i = 0; i < newDisplayedOptions.length; i++) {
      if (newDisplayedOptions[i]?.order == option.order) {
        newDisplayedOptions.removeAt(i);
        newDisplayedOptions.add(null);
        break;
      }
    }

    // apply changes immediately (no stagger) to avoid visual gaps
    setState(() {
      _displayedSelectedSlots = newDisplayedSelected2;
      _displayedOptionSlots = newDisplayedOptions;

      // sync the logical lists
      shuffledOptions.removeWhere((o) => o.order == option.order);
      selectedOrder.add(option);
      _animating.remove(option.order);
    });
  }

  Future<void> _onUnselectOption(MultipleChoiceOption option) async {
    setState(() {
      _animating.add(option.order);
    });
    await _animateTileMove(option, toSelected: false);

    // compute desired displayed slot arrays after the move (unselect)
    final newDisplayedOptions = List<MultipleChoiceOption?>.from(_displayedOptionSlots);
    // put option into first empty option slot
    final optTarget = newDisplayedOptions.indexWhere((e) => e == null);
    final int optIndex = optTarget == -1 ? newDisplayedOptions.length - 1 : optTarget;
    if (optIndex >= 0 && optIndex < newDisplayedOptions.length) {
      newDisplayedOptions[optIndex] = option;
    }

    final newDisplayedSelected = List<MultipleChoiceOption?>.from(_displayedSelectedSlots);
    // remove the option from selected slots
    for (int i = 0; i < newDisplayedSelected.length; i++) {
      if (newDisplayedSelected[i]?.order == option.order) {
        newDisplayedSelected.removeAt(i);
        newDisplayedSelected.add(null);
        break;
      }
    }

    // apply changes immediately (no stagger) to avoid visual gaps
    setState(() {
      _displayedOptionSlots = newDisplayedOptions;
      _displayedSelectedSlots = newDisplayedSelected;

      selectedOrder.removeWhere((o) => o.order == option.order);
      shuffledOptions.add(option);
      _animating.remove(option.order);
    });
  }

  Future<void> _animateTileMove(MultipleChoiceOption option, {required bool toSelected, int? targetIndex}) async {
    final overlay = Overlay.of(context);

    // determine start slot index by locating the option in displayed slots
    int startIndex = -1;
    if (toSelected) {
      for (int i = 0; i < _displayedOptionSlots.length; i++) {
        if (_displayedOptionSlots[i]?.order == option.order) {
          startIndex = i;
          break;
        }
      }
    } else {
      for (int i = 0; i < _displayedSelectedSlots.length; i++) {
        if (_displayedSelectedSlots[i]?.order == option.order) {
          startIndex = i;
          break;
        }
      }
    }

    if (startIndex == -1) return; // can't find source slot

    final startKey = toSelected ? _slotKeyForOptionIndex(startIndex) : _slotKeyForSelectedIndex(startIndex);
    // pick an exact target slot key (use provided targetIndex if any)
    final endKey = toSelected
        ? _slotKeyForSelectedIndex(targetIndex ?? selectedOrder.length)
        : _slotKeyForOptionIndex(targetIndex ?? shuffledOptions.length);

    final startContext = startKey.currentContext;
    final endContext = endKey.currentContext;
    if (startContext == null || endContext == null) return;

    final startBox = startContext.findRenderObject() as RenderBox;
    final endBox = endContext.findRenderObject() as RenderBox;
    final startPos = startBox.localToGlobal(Offset.zero);
    final endPos = endBox.localToGlobal(Offset.zero);
    final tileSize = startBox.size;

    // mark animating so original tile is hidden during fly
    setState(() {
      _animating.add(option.order);
    });

    // center end position inside the end box
  final endCentered = endPos + Offset((endBox.size.width - tileSize.width) / 2, (endBox.size.height - tileSize.height) / 2);

    final controller = AnimationController(vsync: this, duration: _flyDuration);
    final curved = CurvedAnimation(parent: controller, curve: Curves.easeInOut);
    // We'll animate t from 0..1 and evaluate a quadratic bezier for an arc path

    // control point above the line between start and end to make an arc
    final mid = Offset((startPos.dx + endCentered.dx) / 2, (startPos.dy + endCentered.dy) / 2);
    // lift the control point upward by an amount proportional to distance
    final distance = (endCentered - startPos).distance;
    final lift = (80.0 + distance * 0.08).clamp(60.0, 220.0);
    final controlPoint = Offset(mid.dx, mid.dy - lift);

    late OverlayEntry entry;
    entry = OverlayEntry(builder: (context) {
      return AnimatedBuilder(
        animation: curved,
        builder: (context, child) {
          final t = curved.value;
          // quadratic bezier: B(t) = (1-t)^2 * P0 + 2(1-t)t * CP + t^2 * P2
          final oneMinusT = 1.0 - t;
          final pos = Offset(
            oneMinusT * oneMinusT * startPos.dx + 2 * oneMinusT * t * controlPoint.dx + t * t * endCentered.dx,
            oneMinusT * oneMinusT * startPos.dy + 2 * oneMinusT * t * controlPoint.dy + t * t * endCentered.dy,
          );
          final scale = 1.0 - 0.15 * t; // a small scale during fly
          return Positioned(
            left: pos.dx,
            top: pos.dy,
            width: tileSize.width,
            height: tileSize.height,
            child: IgnorePointer(
              ignoring: true,
              child: Transform.scale(
                scale: scale,
                child: Material(
                  color: Colors.transparent,
                  child: WordTile(
                    word: option.text,
                    onPressed: () {},
                    state: WordTileState.defaults,
                  ),
                ),
              ),
            ),
          );
        },
      );
    });

    overlay.insert(entry);
    await controller.forward();
    entry.remove();
    controller.dispose();
  }

  GlobalKey _slotKeyForSelectedIndex(int index) {
    return _selectedSlotKeys.putIfAbsent(index, () => GlobalKey());
  }

  GlobalKey _slotKeyForOptionIndex(int index) {
    return _optionSlotKeys.putIfAbsent(index, () => GlobalKey());
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<ExerciseBloc, ExerciseState>(
        builder: (context, state) {
          if (state is ExercisesLoaded) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  // Use CharacterChallenge for the question
                  CharacterChallenge(
                    statusText: state.isCorrect == null ? "Dạng mới" : null,
                    challengeTitle: "Sắp xếp từ đúng thứ tự",
                    challengeContent: Text(
                      _meta.question,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    character: Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40.w),
                      ),
                      child: Icon(
                        Icons.pets,
                        size: 40.w,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    characterPosition: CharacterPosition.left,
                    variant: _getSpeechBubbleVariant(state),
                  ),
                  SizedBox(height: 30.h),
                  
                  // Selected order area (always present so animation target exists)
                  Container(
                    key: _selectedAreaKey,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Column(
                      children: [
                        if (selectedOrder.isNotEmpty) ...[
                          Text(
                            'Thứ tự đã chọn:',
                            style: TextStyle(
                              color: AppColors.textBlue,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 10.h),
                        ],
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10.w,
                          runSpacing: 10.h,
                                                  children: List.generate(_meta.options.length, (i) {
                            // for each slot index, either show selected tile at that index or placeholder
                            Widget child;
                            if (i < _displayedSelectedSlots.length && _displayedSelectedSlots[i] != null) {
                              final option = _displayedSelectedSlots[i]!;
                              if (_animating.contains(option.order)) {
                                child = const SizedBox.shrink();
                              } else {
                                child = GestureDetector(
                                  onTap: state.isCorrect == null
                                      ? () => _onUnselectOption(option)
                                      : null,
                                  behavior: HitTestBehavior.opaque,
                                  child: IgnorePointer(
                                    ignoring: true,
                                    child: WordTile(
                                      key: ValueKey('selected-${option.order}'),
                                      word: option.text,
                                      onPressed: () {},
                                      state: _getWordTileStateForSelected(state, option),
                                    ),
                                  ),
                                );
                              }
                            } else {
                              child = SizedBox(
                                width: 140.w,
                                height: AppWordTileTokens.height,
                              );
                            }

                            return Container(
                              key: _slotKeyForSelectedIndex(i),
                              width: 140.w,
                              height: AppWordTileTokens.height,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (widget, animation) {
                                  final offsetAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(animation);
                                  return SlideTransition(position: offsetAnimation, child: FadeTransition(opacity: animation, child: widget));
                                },
                                child: child,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  
                  Spacer(),
                  
                  // Available options area
                  Text(
                    'Chọn từ:',
                    style: TextStyle(
                      color: AppColors.textBlue,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    key: _optionsAreaKey,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10.w,
                      runSpacing: 10.h,
                      children: List.generate(_meta.options.length, (i) {
                        Widget child;
                        final slotItem = (i < _displayedOptionSlots.length) ? _displayedOptionSlots[i] : null;
                        if (slotItem != null) {
                          if (_animating.contains(slotItem.order)) {
                            child = const SizedBox.shrink();
                          } else {
                            child = WordTile(
                              key: ValueKey('option-${slotItem.order}'),
                              word: slotItem.text,
                              onPressed: state.isCorrect == null
                                  ? () {
                                      if (_meta.correctOrder.length != selectedOrder.length) {
                                        _onSelectOption(slotItem);
                                      }
                                    }
                                  : () {},
                              state: WordTileState.defaults,
                            );
                          }
                        } else {
                          child = SizedBox(
                            key: _slotKeyForOptionIndex(i),
                            width: 140.w,
                            height: AppWordTileTokens.height,
                          );
                        }

                        return Container(
                          key: _slotKeyForOptionIndex(i),
                          width: 140.w,
                          height: AppWordTileTokens.height,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (widget, animation) {
                              final offsetAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(animation);
                              return SlideTransition(position: offsetAnimation, child: FadeTransition(opacity: animation, child: widget));
                            },
                            child: child,
                          ),
                        );
                      }),
                    ),
                  ),
                  
                  SizedBox(height: 20.h),
                  
                  // Submit button
                  if (state.isCorrect == null)
                    if (selectedOrder.isNotEmpty)
                      CustomButton(
                        color: AppColors.primaryGreen,
                        onTap: handleSubmit,
                        label: "Xác nhận",
                      )
                    else
                      SizedBox.shrink()
                  else
                    SizedBox.shrink(),
                  
                  SizedBox(height: 20.h),
                ],
              ),
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }

  SpeechBubbleVariant _getSpeechBubbleVariant(ExercisesLoaded state) {
    if (state.isCorrect == null) {
      return SpeechBubbleVariant.neutral;
    } else if (state.isCorrect == true) {
      return SpeechBubbleVariant.correct;
    } else {
      return SpeechBubbleVariant.incorrect;
    }
  }

  WordTileState _getWordTileStateForSelected(ExercisesLoaded state, MultipleChoiceOption option) {
    if (state.isCorrect != null) {
      // After submission
      if (state.isCorrect == true) {
        return WordTileState.correct;
      } else {
        return WordTileState.incorrect;
      }
    } else {
      // Before submission - selected state
      return WordTileState.selected;
    }
  }
}
