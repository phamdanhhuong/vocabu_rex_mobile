import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:vocabu_rex_mobile/theme/widgets/challenges/challenge.dart';
import 'package:vocabu_rex_mobile/theme/widgets/speech_bubbles/speech_bubble.dart';
import 'package:vocabu_rex_mobile/theme/widgets/word_tiles/app_choice_tile.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/exercise_feedback.dart';

class FillBlank extends StatefulWidget {
  final FillBlankMetaEntity meta;
  final String exerciseId;
  final VoidCallback? onContinue;
  
  const FillBlank({
    super.key,
    required this.meta,
    required this.exerciseId,
    this.onContinue,
  });

  @override
  State<FillBlank> createState() => _FillBlankState();
}

class _FillBlankState extends State<FillBlank> with TickerProviderStateMixin {
  FillBlankMetaEntity get _meta => widget.meta;
  String get _exerciseId => widget.exerciseId;
  
  // Track selected options for each blank
  final List<String?> _selectedAnswers = [];
  late List<String> _availableOptions;
  
  // Animation tracking
  final Map<String, GlobalKey> _optionPlaceholderKeys = {};
  final Map<int, GlobalKey> _blankSlotKeys = {};
  final Duration _flyDuration = const Duration(milliseconds: 400);
  final Set<String> _animating = {};
  
  bool _isSubmitted = false;
  bool _isLoading = false;
  
  // Entry animations
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize selected answers (null = empty)
    for (int i = 0; i < _meta.sentences.length; i++) {
      _selectedAnswers.add(null);
      _blankSlotKeys[i] = GlobalKey();
    }
    
    // Collect all options and shuffle
    final allOpts = <String>{};
    for (var sentence in _meta.sentences) {
      if (sentence.options != null) {
        allOpts.addAll(sentence.options!);
      }
    }
    _availableOptions = allOpts.toList()..shuffle();
    
    // Create placeholder keys
    for (var option in _availableOptions) {
      _optionPlaceholderKeys[option] = GlobalKey();
    }
    
    // Initialize entry animations
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );
    
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _onSelectOption(String option) async {
    if (_animating.contains(option) || _isSubmitted) return;
    
    // Find first empty blank
    final emptyIndex = _selectedAnswers.indexWhere((a) => a == null);
    if (emptyIndex == -1) return;
    
    setState(() {
      _animating.add(option);
    });
    
    await _animateTileMove(option, toBlankIndex: emptyIndex, toBlank: true);
    
    setState(() {
      _selectedAnswers[emptyIndex] = option;
      _animating.remove(option);
    });
  }

  Future<void> _onUnselectOption(int blankIndex) async {
    final option = _selectedAnswers[blankIndex];
    if (option == null || _animating.contains(option) || _isSubmitted) return;
    
    setState(() {
      _animating.add(option);
    });
    
    await _animateTileMove(option, toBlankIndex: blankIndex, toBlank: false);
    
    setState(() {
      _selectedAnswers[blankIndex] = null;
      _animating.remove(option);
    });
  }

  Future<void> _animateTileMove(
    String option, {
    required int toBlankIndex,
    required bool toBlank,
  }) async {
    final overlay = Overlay.of(context);
    
    GlobalKey? startKey;
    GlobalKey? endKey;
    
    if (toBlank) {
      startKey = _optionPlaceholderKeys[option];
      endKey = _blankSlotKeys[toBlankIndex];
    } else {
      startKey = _blankSlotKeys[toBlankIndex];
      endKey = _optionPlaceholderKeys[option];
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
                  text: option,
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
    final userAnswers = _selectedAnswers.whereType<String>().toList();
    final correctAnswers = _meta.sentences.map((s) => s.correctAnswer).toList();
    
    if (userAnswers.length != correctAnswers.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng điền đầy đủ tất cả đáp án'),
          backgroundColor: AppColors.cardinal,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    setState(() {
      _isSubmitted = true;
      _isLoading = true;
    });
    
    context.read<ExerciseBloc>().add(
      FilledBlank(
        listAnswer: userAnswers,
        listCorrectAnswer: correctAnswers,
        exerciseId: _exerciseId,
      ),
    );
  }

  void _handleContinue() {
    context.read<ExerciseBloc>().add(AnswerClear());
    if (widget.onContinue != null) {
      widget.onContinue!();
    } else {
      setState(() {
        _selectedAnswers.fillRange(0, _selectedAnswers.length, null);
        _isSubmitted = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseBloc, ExerciseState>(
      builder: (context, state) {
        if (state is! ExercisesLoaded) {
          return const SizedBox.shrink();
        }

        final isCorrect = state.isCorrect;
        if (_isLoading && isCorrect != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _isLoading = false);
          });
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Challenge header
            if (_meta.context != null && _meta.context!.isNotEmpty)
              AnimatedBuilder(
                animation: _entryController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        child: CharacterChallenge(
                          challengeTitle: 'Điền vào chỗ trống',
                          challengeContent: Text(
                            _meta.context!,
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                          ),
                          character: Container(
                            width: 80.w,
                            height: 80.h,
                            decoration: BoxDecoration(
                              color: AppColors.beetle.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.edit, size: 40.sp, color: AppColors.beetle),
                          ),
                          characterPosition: CharacterPosition.left,
                          variant: isCorrect == null
                              ? SpeechBubbleVariant.neutral
                              : (isCorrect ? SpeechBubbleVariant.correct : SpeechBubbleVariant.incorrect),
                        ),
                      ),
                    ),
                  );
                },
              ),
            
            // Scrollable content area
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    SizedBox(height: 8.h),
                    
                    // Sentences with blanks area (selected slots)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.swan, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(_meta.sentences.length, (index) {
                          final sentence = _meta.sentences[index].text;
                          final parts = sentence.split("___");
                          final selectedOption = _selectedAnswers[index];
                          final isAnimating = selectedOption != null && _animating.contains(selectedOption);
                          
                          // Determine tile state after submission
                          ChoiceTileState tileState = ChoiceTileState.defaults;
                          if (_isSubmitted && selectedOption != null) {
                            final correctAnswer = _meta.sentences[index].correctAnswer;
                            tileState = selectedOption == correctAnswer
                                ? ChoiceTileState.correct
                                : ChoiceTileState.incorrect;
                          }
                          
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                // Left part
                                if (parts.isNotEmpty && parts[0].isNotEmpty)
                                  Text(
                                    parts[0],
                                    style: TextStyle(
                                      color: AppColors.eel,
                                      fontSize: 18.sp,
                                      height: 1.5,
                                    ),
                                  ),
                                
                                // Blank slot
                                KeyedSubtree(
                                  key: _blankSlotKeys[index]!,
                                  child: selectedOption == null
                                      ? Container(
                                          width: 120.w,
                                          height: 40.h,
                                          margin: EdgeInsets.symmetric(horizontal: 4.w),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: AppColors.hare,
                                                width: 3,
                                              ),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '',
                                              style: TextStyle(fontSize: 16.sp),
                                            ),
                                          ),
                                        )
                                      : Opacity(
                                          opacity: isAnimating ? 0.0 : 1.0,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                                            child: ChoiceTile(
                                              text: selectedOption,
                                              state: tileState,
                                              onPressed: _isSubmitted
                                                  ? () {}
                                                  : () => _onUnselectOption(index),
                                            ),
                                          ),
                                        ),
                                ),
                                
                                // Right part
                                if (parts.length > 1 && parts[1].isNotEmpty)
                                  Text(
                                    parts[1],
                                    style: TextStyle(
                                      color: AppColors.eel,
                                      fontSize: 18.sp,
                                      height: 1.5,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Available options area
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: _availableOptions.map((option) {
                        final isSelected = _selectedAnswers.contains(option);
                        final isAnimating = _animating.contains(option);
                        
                        return KeyedSubtree(
                          key: _optionPlaceholderKeys[option]!,
                          child: Opacity(
                            opacity: (isSelected || isAnimating) ? 0.0 : 1.0,
                            child: ChoiceTile(
                              text: option,
                              state: ChoiceTileState.defaults,
                              onPressed: (_isSubmitted || isSelected)
                                  ? () {}
                                  : () => _onSelectOption(option),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
            
            // Action buttons (fixed at bottom)
            if (isCorrect != null)
              ExerciseFeedback(
                isCorrect: isCorrect,
                onContinue: _handleContinue,
                correctAnswer: isCorrect ? null : _meta.sentences.map((s) => s.correctAnswer).join(' '),
              )
            else
              _buildCheckButton(),
          ],
        );
      },
    );
  }

  Widget _buildCheckButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: AppButton(
        label: 'KIỂM TRA',
        onPressed: _handleSubmit,
        isDisabled: _selectedAnswers.any((a) => a == null),
        isLoading: _isLoading,
        variant: ButtonVariant.primary,
        size: ButtonSize.medium,
      ),
    );
  }
}
