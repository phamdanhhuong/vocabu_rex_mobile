import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
import 'package:vocabu_rex_mobile/theme/widgets/word_tiles/app_choice_tile.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:vocabu_rex_mobile/theme/widgets/challenges/challenge.dart';
import 'package:vocabu_rex_mobile/theme/widgets/speech_bubbles/speech_bubble.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/exercise_feedback.dart';

/// Complex multiple choice UI - when correctOrder.length > 1
/// Displays options with fixed positions and animated transitions
class MultipleChoiceComplex extends StatefulWidget {
  final MultipleChoiceMetaEntity meta;
  final String exerciseId;
  final VoidCallback? onContinue;
  
  const MultipleChoiceComplex({
    Key? key,
    required this.meta,
    required this.exerciseId,
    this.onContinue,
  }) : super(key: key);

  @override
  State<MultipleChoiceComplex> createState() => _MultipleChoiceComplexState();
}

class _MultipleChoiceComplexState extends State<MultipleChoiceComplex>
    with TickerProviderStateMixin {
  List<MultipleChoiceOption> selectedOrder = [];
  late List<MultipleChoiceOption> allOptions;
  
  // Track original positions for each option
  final Map<int, GlobalKey> _optionPlaceholderKeys = {};
  final Map<int, GlobalKey> _selectedSlotKeys = {};
  final Duration _flyDuration = const Duration(milliseconds: 400);
  final Set<int> _animating = {};
  
  // Tracks which options are in correct/incorrect states after submission
  final Map<int, AnimationController> _colorControllers = {};
  Set<int> _correctOptions = {};
  Set<int> _incorrectOptions = {};
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    allOptions = List<MultipleChoiceOption>.from(widget.meta.options)..shuffle();
    
    // Create animation controllers for each option
    for (var option in widget.meta.options) {
      _colorControllers[option.order] = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _colorControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _onSelectOption(MultipleChoiceOption option) async {
    if (_animating.contains(option.order) || _isSubmitted) return;
    
    setState(() {
      _animating.add(option.order);
    });
    
    await _animateTileMove(option, toSelected: true);
    
    setState(() {
      selectedOrder.add(option);
      _animating.remove(option.order);
    });
  }

  Future<void> _onUnselectOption(MultipleChoiceOption option, int selectedIndex) async {
    if (_animating.contains(option.order) || _isSubmitted) return;
    
    // Mark all affected tiles as animating
    final tilesToShift = selectedOrder.sublist(selectedIndex + 1);
    setState(() {
      _animating.add(option.order);
      for (var tile in tilesToShift) {
        _animating.add(tile.order);
      }
    });
    
    // Animate the removed tile flying back
    await _animateTileMove(option, toSelected: false, fromSelectedIndex: selectedIndex);
    
    // Animate remaining tiles shifting left
    if (tilesToShift.isNotEmpty) {
      await _animateShiftLeft(tilesToShift, selectedIndex);
    }
    
    setState(() {
      selectedOrder.removeAt(selectedIndex);
      _animating.remove(option.order);
      for (var tile in tilesToShift) {
        _animating.remove(tile.order);
      }
    });
  }

  Future<void> _animateShiftLeft(List<MultipleChoiceOption> tiles, int fromIndex) async {
    // Get start and end positions for each tile
    final List<Future<void>> animations = [];
    
    for (int i = 0; i < tiles.length; i++) {
      final tile = tiles[i];
      final currentIndex = fromIndex + 1 + i;
      final targetIndex = fromIndex + i;
      
      final startKey = _selectedSlotKeys[currentIndex];
      final endKey = _selectedSlotKeys[targetIndex];
      
      if (startKey?.currentContext == null || endKey?.currentContext == null) continue;
      
      final startBox = startKey!.currentContext!.findRenderObject() as RenderBox;
      final endBox = endKey!.currentContext!.findRenderObject() as RenderBox;
      final startPos = startBox.localToGlobal(Offset.zero);
      final endPos = endBox.localToGlobal(Offset.zero);
      final tileSize = startBox.size;
      
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      );
      final curved = CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic);
      
      final overlay = Overlay.of(context);
      late OverlayEntry entry;
      entry = OverlayEntry(
        builder: (context) {
          return AnimatedBuilder(
            animation: curved,
            builder: (context, child) {
              final t = curved.value;
              final currentPos = Offset.lerp(startPos, endPos, t)!;
              
              return Positioned(
                left: currentPos.dx,
                top: currentPos.dy,
                width: tileSize.width,
                height: tileSize.height,
                child: Material(
                  color: Colors.transparent,
                  child: ChoiceTile(
                    text: tile.text,
                    state: ChoiceTileState.defaults,
                    onPressed: () {},
                  ),
                ),
              );
            },
          );
        },
      );
      
      overlay.insert(entry);
      animations.add(controller.forward().then((_) {
        entry.remove();
        controller.dispose();
      }));
    }
    
    await Future.wait(animations);
  }

  Future<void> _animateTileMove(
    MultipleChoiceOption option, {
    required bool toSelected,
    int? fromSelectedIndex,
  }) async {
    final overlay = Overlay.of(context);
    
    // Find source and target positions
    GlobalKey? startKey;
    GlobalKey? endKey;
    
    if (toSelected) {
      // Moving from placeholder to selected
      startKey = _optionPlaceholderKeys[option.order];
      endKey = _selectedSlotKeys[selectedOrder.length];
    } else {
      // Moving from selected back to placeholder
      startKey = _selectedSlotKeys[fromSelectedIndex ?? 0];
      endKey = _optionPlaceholderKeys[option.order];
    }
    
    if (startKey?.currentContext == null || endKey?.currentContext == null) {
      return;
    }
    
    final startBox = startKey!.currentContext!.findRenderObject() as RenderBox;
    final endBox = endKey!.currentContext!.findRenderObject() as RenderBox;
    final startPos = startBox.localToGlobal(Offset.zero);
    final endPos = endBox.localToGlobal(Offset.zero);
    final tileSize = startBox.size;
    
    final controller = AnimationController(vsync: this, duration: _flyDuration);
    final curved = CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic);
    
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return AnimatedBuilder(
          animation: curved,
          builder: (context, child) {
            final t = curved.value;
            final currentPos = Offset.lerp(startPos, endPos, t)!;
            
            return Positioned(
              left: currentPos.dx,
              top: currentPos.dy,
              width: tileSize.width,
              height: tileSize.height,
              child: Material(
                color: Colors.transparent,
                child: ChoiceTile(
                  text: option.text,
                  state: ChoiceTileState.defaults,
                  onPressed: () {},
                ),
              ),
            );
          },
        );
      },
    );
    
    overlay.insert(entry);
    await controller.forward();
    entry.remove();
    controller.dispose();
  }

  void _handleSubmit() {
    final selectedOrderIds = selectedOrder.map((o) => o.order).toList();
    
    // Check correctness for each position
    _correctOptions.clear();
    _incorrectOptions.clear();
    
    for (int i = 0; i < selectedOrderIds.length; i++) {
      if (i < widget.meta.correctOrder.length && 
          selectedOrderIds[i] == widget.meta.correctOrder[i]) {
        _correctOptions.add(selectedOrder[i].order);
      } else {
        _incorrectOptions.add(selectedOrder[i].order);
      }
    }
    
    setState(() {
      _isSubmitted = true;
    });
    
    // Trigger color animations
    for (var optionOrder in _correctOptions) {
      _colorControllers[optionOrder]?.forward(from: 0.0);
    }
    for (var optionOrder in _incorrectOptions) {
      _colorControllers[optionOrder]?.forward(from: 0.0);
    }
    
    // Submit to bloc
    Future.delayed(const Duration(milliseconds: 100), () {
      context.read<ExerciseBloc>().add(
        AnswerSelected(
          selectedAnswer: selectedOrder.map((o) => o.text).join(' '),
          correctAnswer: widget.meta.correctOrder
              .map((id) => widget.meta.options.firstWhere((o) => o.order == id).text)
              .join(' '),
          exerciseId: widget.exerciseId,
        ),
      );
    });
  }

  ChoiceTileState _getTileState(MultipleChoiceOption option) {
    if (!_isSubmitted) return ChoiceTileState.defaults;
    
    if (_correctOptions.contains(option.order)) {
      return ChoiceTileState.correct;
    } else if (_incorrectOptions.contains(option.order)) {
      return ChoiceTileState.incorrect;
    }
    return ChoiceTileState.defaults;
  }

  Widget _buildStarParticles(MultipleChoiceOption option) {
    final controller = _colorControllers[option.order]!;
    final random = math.Random(option.text.hashCode);
    
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final opacity = controller.value < 0.2
            ? controller.value / 0.2
            : controller.value < 1.0
                ? 1.0 - ((controller.value - 0.2) / 0.8)
                : 0.0;
        
        return Stack(
          clipBehavior: Clip.none,
          children: List.generate(8, (index) {
            final angle = (index * math.pi * 2 / 8);
            final distance = 30.0 + random.nextDouble() * 20.0;
            final dx = math.cos(angle) * distance * controller.value;
            final dy = math.sin(angle) * distance * controller.value;
            
            return Positioned(
              left: dx,
              top: dy,
              child: Opacity(
                opacity: opacity,
                child: Icon(
                  Icons.star,
                  size: 12.sp + random.nextDouble() * 8.sp,
                  color: AppColors.bee,
                ),
              ),
            );
          }),
        );
      },
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
                challengeTitle: 'Viết lại bằng Tiếng Việt',
                challengeContent: Text(
                  widget.meta.question,
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                ),
                character: Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: Colors.brown[300],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.pets, size: 40.sp, color: Colors.white),
                ),
                characterPosition: CharacterPosition.left,
                variant: _isSubmitted
                    ? (isCorrect == true ? SpeechBubbleVariant.correct : SpeechBubbleVariant.incorrect)
                    : SpeechBubbleVariant.neutral,
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Selected words area
            Container(
              padding: EdgeInsets.all(16.w),
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!, width: 2),
                ),
              ),
              constraints: BoxConstraints(minHeight: 60.h),
              child: Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  ...selectedOrder.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final isAnimating = _animating.contains(option.order);
                    final isCorrectOption = _correctOptions.contains(option.order);
                    
                    return KeyedSubtree(
                      key: _selectedSlotKeys.putIfAbsent(index, () => GlobalKey()),
                      child: Opacity(
                        opacity: isAnimating ? 0.0 : 1.0,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ChoiceTile(
                              text: option.text,
                              state: _getTileState(option),
                              onPressed: _isSubmitted 
                                  ? () {}
                                  : () => _onUnselectOption(option, index),
                            ),
                            if (_isSubmitted && isCorrectOption)
                              _buildStarParticles(option),
                          ],
                        ),
                      ),
                    );
                  }),
                  // Empty slots for remaining positions
                  ...List.generate(
                    math.max(0, widget.meta.correctOrder.length - selectedOrder.length),
                    (index) {
                      final slotIndex = selectedOrder.length + index;
                      return KeyedSubtree(
                        key: _selectedSlotKeys.putIfAbsent(slotIndex, () => GlobalKey()),
                        child: Container(
                          width: 80.w,
                          height: 48.h,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[400]!, width: 2),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Available options with fixed placeholders
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: allOptions.map((option) {
                    final isSelected = selectedOrder.any((o) => o.order == option.order);
                    final isAnimating = _animating.contains(option.order);
                    
                    return KeyedSubtree(
                      key: _optionPlaceholderKeys.putIfAbsent(option.order, () => GlobalKey()),
                      child: Opacity(
                        opacity: (isSelected || isAnimating) ? 0.0 : 1.0,
                        child: ChoiceTile(
                          text: option.text,
                          state: ChoiceTileState.defaults,
                          onPressed: _isSubmitted ? () {} : () => _onSelectOption(option),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Action buttons
            if (_isSubmitted)
              ExerciseFeedback(
                isCorrect: _correctOptions.length == widget.meta.correctOrder.length && _incorrectOptions.isEmpty,
                onContinue: () {
                  context.read<ExerciseBloc>().add(AnswerClear());
                  if (widget.onContinue != null) {
                    widget.onContinue!();
                  } else {
                    setState(() {
                      selectedOrder.clear();
                      _correctOptions.clear();
                      _incorrectOptions.clear();
                      _isSubmitted = false;
                      allOptions.shuffle();
                      for (var controller in _colorControllers.values) {
                        controller.reset();
                      }
                    });
                  }
                },
                correctAnswer: (_correctOptions.length == widget.meta.correctOrder.length && _incorrectOptions.isEmpty)
                    ? null
                    : widget.meta.correctOrder
                        .map((id) => widget.meta.options.firstWhere((o) => o.order == id).text)
                        .join(' '),
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: AppButton(
                  label: 'KIỂM TRA',
                  onPressed: _handleSubmit,
                  isDisabled: selectedOrder.length != widget.meta.correctOrder.length,
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
