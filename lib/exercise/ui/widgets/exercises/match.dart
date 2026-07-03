import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vocabu_rex_mobile/core/utils/tts_helper.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:vocabu_rex_mobile/theme/widgets/word_tiles/app_match_tile.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/exercise_feedback.dart';

class DrawnLine {
  final String leftItem;
  final String rightItem;
  final Offset start;
  final Offset end;
  final Color color;

  DrawnLine(this.leftItem, this.rightItem, this.start, this.end, this.color);
}

class MatchLinesPainter extends CustomPainter {
  final List<DrawnLine> fixedLines;
  final Offset? activeStart;
  final Offset? activeEnd;
  final Color activeColor;

  MatchLinesPainter({
    required this.fixedLines,
    this.activeStart,
    this.activeEnd,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    // Draw fixed lines
    for (var line in fixedLines) {
      paint.color = line.color;
      _drawBezier(canvas, line.start, line.end, paint);
    }

    // Draw active dragging line
    if (activeStart != null && activeEnd != null) {
      paint.color = activeColor;
      _drawBezier(canvas, activeStart!, activeEnd!, paint);
    }
  }

  void _drawBezier(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    final path = Path();
    path.moveTo(p1.dx, p1.dy);
    
    // Create S-curve by adding control points horizontally extended
    final distance = (p2.dx - p1.dx).abs();
    final controlPointOffset = distance * 0.5;
    
    path.cubicTo(
      p1.dx + controlPointOffset, p1.dy,
      p2.dx - controlPointOffset, p2.dy,
      p2.dx, p2.dy,
    );
    
    // Add glow effect for correct (green) lines
    if (paint.color == AppColors.correctGreenDark || paint.color == AppColors.featherGreen) {
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12.0
        ..strokeCap = StrokeCap.round
        ..color = paint.color.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
      canvas.drawPath(path, glowPaint);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant MatchLinesPainter oldDelegate) => true;
}

class MatchExercise extends StatefulWidget {
  final MatchMetaEntity meta;
  final String exerciseId;
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

class _MatchExerciseState extends State<MatchExercise> with TickerProviderStateMixin {
  MatchMetaEntity get _meta => widget.meta;
  String get _exerciseId => widget.exerciseId;

  late List<String> leftItems;
  late List<String> rightItems;
  String? selectedLeft;
  String? selectedRight;
  Set<String> matchedLeft = {};
  Set<String> matchedRight = {};
  Set<String> correctLeft = {};
  Set<String> correctRight = {};
  Set<String> incorrectLeft = {};
  Set<String> incorrectRight = {};
  bool _revealed = false;
  bool _isLoading = false;

  FlutterTts flutterTts = FlutterTts();

  // Draw Line state
  final GlobalKey _stackKey = GlobalKey();
  final Map<String, GlobalKey> _leftKeys = {};
  final Map<String, GlobalKey> _rightKeys = {};
  List<DrawnLine> _fixedLines = [];
  String? _draggingLeftItem;
  Offset? _activeDragStart;
  Offset? _activeDragEnd;
  Color _activeDragColor = AppColors.selectionBlueDark;

  // Entry animations
  late AnimationController _entryController;
  final List<Animation<double>> _leftSlideAnimations = [];
  final List<Animation<double>> _rightSlideAnimations = [];
  final List<Animation<double>> _fadeAnimations = [];

  Future<void> speak(String text) async {
    await TtsHelper.setDynamicVoice(flutterTts, 'female', locale: 'en-us');
    await flutterTts.setSpeechRate(AppPreferences().isVoiceSpeedNormal ? 0.5 : 0.3);
    await flutterTts.setVolume(1.3);
    await flutterTts.speak(text);
  }

  @override
  void initState() {
    super.initState();
    leftItems = _meta.pairs.map((p) => p.left).toList();
    rightItems = _meta.pairs.map((p) => p.right).toList()..shuffle();

    for (var item in leftItems) _leftKeys[item] = GlobalKey();
    for (var item in rightItems) _rightKeys[item] = GlobalKey();

    _entryController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    for (int i = 0; i < leftItems.length; i++) {
      final delay = i * 0.1;
      _leftSlideAnimations.add(Tween<double>(begin: -50, end: 0).animate(CurvedAnimation(parent: _entryController, curve: Interval(delay, delay + 0.4, curve: Curves.easeOutCubic))));
      _rightSlideAnimations.add(Tween<double>(begin: 50, end: 0).animate(CurvedAnimation(parent: _entryController, curve: Interval(delay, delay + 0.4, curve: Curves.easeOutCubic))));
      _fadeAnimations.add(Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _entryController, curve: Interval(delay, delay + 0.4, curve: Curves.easeIn))));
    }
    _entryController.forward();
  }

  Offset? _getTileCenterRight(GlobalKey key) {
    if (key.currentContext == null || _stackKey.currentContext == null) return null;
    final RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
    final RenderBox stackBox = _stackKey.currentContext!.findRenderObject() as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero, ancestor: stackBox);
    return Offset(position.dx + box.size.width - 8.w, position.dy + box.size.height / 2);
  }

  Offset? _getTileCenterLeft(GlobalKey key) {
    if (key.currentContext == null || _stackKey.currentContext == null) return null;
    final RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
    final RenderBox stackBox = _stackKey.currentContext!.findRenderObject() as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero, ancestor: stackBox);
    return Offset(position.dx + 8.w, position.dy + box.size.height / 2);
  }

  void _onPanStart(DragStartDetails details, String item) {
    if (matchedLeft.contains(item) || correctLeft.contains(item)) return;
    setState(() {
      _draggingLeftItem = item;
      selectedLeft = item;
      _activeDragStart = _getTileCenterRight(_leftKeys[item]!);
      
      // Get local offset from global drag position
      if (_stackKey.currentContext != null) {
        final RenderBox stackBox = _stackKey.currentContext!.findRenderObject() as RenderBox;
        _activeDragEnd = stackBox.globalToLocal(details.globalPosition);
      } else {
        _activeDragEnd = details.localPosition;
      }
      _activeDragColor = AppColors.selectionBlueDark;
    });
    _playPause(item);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_draggingLeftItem == null) return;
    setState(() {
      if (_stackKey.currentContext != null) {
        final RenderBox stackBox = _stackKey.currentContext!.findRenderObject() as RenderBox;
        final localPos = stackBox.globalToLocal(details.globalPosition);
        
        // Magnetic snap: check if near any right item
        Offset snapPos = localPos;
        for (var rightItem in rightItems) {
          if (matchedRight.contains(rightItem)) continue;
          final targetPos = _getTileCenterLeft(_rightKeys[rightItem]!);
          if (targetPos != null) {
            final distance = (targetPos - localPos).distance;
            if (distance < 50.w) { // Magnetic radius
              snapPos = targetPos;
              selectedRight = rightItem; // Hover selection
              break;
            } else if (selectedRight == rightItem) {
              selectedRight = null;
            }
          }
        }
        _activeDragEnd = snapPos;
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_draggingLeftItem == null) return;
    final left = _draggingLeftItem!;
    final right = selectedRight;
    
    if (right != null && !matchedRight.contains(right)) {
      _processMatch(left, right);
    } else {
      // Cancel drag
      setState(() {
        _draggingLeftItem = null;
        selectedLeft = null;
        selectedRight = null;
        _activeDragStart = null;
        _activeDragEnd = null;
      });
    }
  }

  void handleSelection(String item, bool isLeft) {
    if (_draggingLeftItem != null) return; // Ignore tap during drag
    
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
        _processMatch(selectedLeft!, selectedRight!);
      }
    });
  }

  void _processMatch(String left, String right) {
    final start = _getTileCenterRight(_leftKeys[left]!);
    final end = _getTileCenterLeft(_rightKeys[right]!);
    if (start == null || end == null) return;

    final correctPair = widget.meta.pairs.firstWhere(
      (p) => p.left == left && p.right == right,
      orElse: () => MatchPair(left: '', right: ''),
    );

    if (correctPair.left.isNotEmpty) {
      // Correct!
      setState(() {
        correctLeft.add(left);
        correctRight.add(right);
        _fixedLines.add(DrawnLine(left, right, start, end, AppColors.featherGreen));
      });

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
      // Incorrect!
      setState(() {
        incorrectLeft.add(left);
        incorrectRight.add(right);
        _fixedLines.add(DrawnLine(left, right, start, end, AppColors.cardinal));
      });

      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            incorrectLeft.remove(left);
            incorrectRight.remove(right);
            _fixedLines.removeWhere((l) => l.leftItem == left && l.rightItem == right);
          });
        }
      });
    }

    setState(() {
      _draggingLeftItem = null;
      selectedLeft = null;
      selectedRight = null;
      _activeDragStart = null;
      _activeDragEnd = null;
    });

    if (matchedLeft.length + correctLeft.length == leftItems.length) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          context.read<ExerciseBloc>().add(AnswerSelected(selectedAnswer: "done", correctAnswer: "done", exerciseId: _exerciseId));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseBloc, ExerciseState>(
      builder: (context, state) {
        if (state is ExercisesLoaded) {
          final isCorrectGlob = state.isCorrect;
          if (_isLoading && isCorrectGlob != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _isLoading = false);
            });
          }
          return Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: 12.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Text('Nối các cặp tương ứng', style: TextStyle(color: AppColors.eel, fontSize: 18.sp, fontWeight: FontWeight.w700)),
                ),
              ),
              SizedBox(height: 8.h),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxRows = max(leftItems.length, rightItems.length);
                    final availableHeight = max(0.0, constraints.maxHeight);
                    final tileHeight = (maxRows > 0 ? (availableHeight / maxRows) : 140.h).clamp(48.h, 180.h);

                    return SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Stack(
                        key: _stackKey,
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: MatchLinesPainter(
                                fixedLines: _fixedLines,
                                activeStart: _activeDragStart,
                                activeEnd: _activeDragEnd,
                                activeColor: _activeDragColor,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left column
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: leftItems.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final item = entry.value;
                                    final isMatched = matchedLeft.contains(item);
                                    final isCorrect = correctLeft.contains(item);
                                    final isIncorrect = incorrectLeft.contains(item);
                                    final isSelected = selectedLeft == item;
                                    final state = _revealed || isMatched ? MatchTileState.disabled : isCorrect ? MatchTileState.correct : isIncorrect ? MatchTileState.incorrect : isSelected ? MatchTileState.selected : MatchTileState.defaults;
                                    
                                    return AnimatedBuilder(
                                      animation: _entryController,
                                      builder: (context, child) {
                                        return Transform.translate(
                                          offset: Offset(_leftSlideAnimations[index].value, 0),
                                          child: Opacity(
                                            opacity: _fadeAnimations[index].value,
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(vertical: 4.h),
                                              child: GestureDetector(
                                                onPanStart: (state == MatchTileState.disabled || state == MatchTileState.correct || state == MatchTileState.incorrect) ? null : (d) => _onPanStart(d, item),
                                                onPanUpdate: (state == MatchTileState.disabled || state == MatchTileState.correct || state == MatchTileState.incorrect) ? null : _onPanUpdate,
                                                onPanEnd: (state == MatchTileState.disabled || state == MatchTileState.correct || state == MatchTileState.incorrect) ? null : _onPanEnd,
                                                child: Container(
                                                  key: _leftKeys[item],
                                                  child: MatchTile(
                                                    word: item,
                                                    state: state,
                                                    height: tileHeight,
                                                    showSoundIcon: true,
                                                    onPressed: (isMatched || isCorrect || isIncorrect) ? null : () => handleSelection(item, true),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                              SizedBox(width: 48.w),
                              // Right column
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: rightItems.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final item = entry.value;
                                    final isMatched = matchedRight.contains(item);
                                    final isCorrect = correctRight.contains(item);
                                    final isIncorrect = incorrectRight.contains(item);
                                    final isSelected = selectedRight == item;
                                    final state = _revealed || isMatched ? MatchTileState.disabled : isCorrect ? MatchTileState.correct : isIncorrect ? MatchTileState.incorrect : isSelected ? MatchTileState.selected : MatchTileState.defaults;
                                    
                                    return AnimatedBuilder(
                                      animation: _entryController,
                                      builder: (context, child) {
                                        return Transform.translate(
                                          offset: Offset(_rightSlideAnimations[index].value, 0),
                                          child: Opacity(
                                            opacity: _fadeAnimations[index].value,
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(vertical: 4.h),
                                              child: Container(
                                                key: _rightKeys[item],
                                                child: MatchTile(
                                                  word: item,
                                                  state: state,
                                                  height: tileHeight,
                                                  showSoundIcon: false,
                                                  onPressed: (isMatched || isCorrect || isIncorrect) ? null : () => handleSelection(item, false),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 40.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: BlocBuilder<ExerciseBloc, ExerciseState>(
                  builder: (ctx, bState) {
                    final hasInteraction = matchedLeft.isNotEmpty || matchedRight.isNotEmpty || selectedLeft != null || selectedRight != null;
                    final isCorrect = (bState is ExercisesLoaded) ? bState.isCorrect : null;
                    if (isCorrect != null) {
                      return ExerciseFeedback(isCorrect: isCorrect, onContinue: () { ctx.read<ExerciseBloc>().add(AnswerClear()); if (widget.onContinue != null) widget.onContinue!(); }, hint: _revealed ? 'Bạn đã xem gợi ý!' : null, isSkipped: _revealed);
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppButton(label: "HIỆN KHÔNG NGHE ĐƯỢC".toUpperCase(), onPressed: () {
                          setState(() { _revealed = true; matchedLeft = leftItems.toSet(); matchedRight = rightItems.toSet(); _isLoading = true; });
                          ctx.read<ExerciseBloc>().add(AnswerSelected(selectedAnswer: "done", correctAnswer: "done", exerciseId: _exerciseId));
                        }, isDisabled: !hasInteraction, variant: ButtonVariant.outline, size: ButtonSize.medium),
                        SizedBox(height: 12.h),
                        AppButton(label: "KIỂM TRA".toUpperCase(), onPressed: () {
                          setState(() => _isLoading = true);
                          if (matchedLeft.length == leftItems.length) {
                            ctx.read<ExerciseBloc>().add(AnswerSelected(selectedAnswer: "done", correctAnswer: "done", exerciseId: _exerciseId));
                          } else {
                            ctx.read<ExerciseBloc>().add(AnswerSelected(selectedAnswer: matchedLeft.join(','), correctAnswer: matchedRight.join(','), exerciseId: _exerciseId));
                          }
                        }, isDisabled: matchedLeft.length != leftItems.length, isLoading: _isLoading, variant: ButtonVariant.primary, size: ButtonSize.medium),
                      ],
                    );
                  },
                ),
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
