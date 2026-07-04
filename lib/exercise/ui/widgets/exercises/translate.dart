import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:vocabu_rex_mobile/theme/widgets/challenges/challenge.dart';
import 'package:vocabu_rex_mobile/theme/widgets/speech_bubbles/speech_bubble.dart';
import 'package:vocabu_rex_mobile/theme/widgets/word_tiles/app_choice_tile.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/exercise_feedback.dart';

enum TranslateMode { keyboard, wordBank }

class WordItem {
  final String id;
  final String text;
  WordItem({required this.id, required this.text});
  
  @override
  bool operator ==(Object other) => identical(this, other) || other is WordItem && runtimeType == other.runtimeType && id == other.id;
  @override
  int get hashCode => id.hashCode;
}

class Translate extends StatefulWidget {
  final TranslateMetaEntity meta;
  final String exerciseId;
  final VoidCallback? onContinue;

  const Translate({
    super.key,
    required this.meta,
    required this.exerciseId,
    this.onContinue,
  });

  @override
  State<Translate> createState() => _TranslateState();
}

class _TranslateState extends State<Translate> with TickerProviderStateMixin {
  TranslateMetaEntity get _meta => widget.meta;
  String get _exerciseId => widget.exerciseId;

  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSubmitted = false;
  bool _isLoading = false;
  
  TranslateMode _mode = TranslateMode.wordBank;

  // Word Bank mode states
  late List<WordItem> _allWordBank;
  final List<WordItem> _selectedWords = [];
  
  final Map<String, GlobalKey> _bankPlaceholderKeys = {};
  final Map<int, GlobalKey> _selectedSlotKeys = {};
  final Set<String> _animating = {};

  // Animation for text field feedback
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _controller.addListener(() {
      setState(() {});
    });

    _initWordBank();
  }

  void _initWordBank() {
    final cleanAnswer = _meta.correctAnswer.replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), '');
    final words = cleanAnswer.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    _allWordBank = words.asMap().entries.map((e) => WordItem(id: 'wb_${e.key}_${e.value}', text: e.value)).toList()..shuffle();
    for (var w in _allWordBank) {
      _bankPlaceholderKeys[w.id] = GlobalKey();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  String normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  void _handleSubmit() {
    String userInput = "";
    if (_mode == TranslateMode.keyboard) {
      if (_controller.text.trim().isEmpty) {
        _shakeController.forward(from: 0);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vui lòng nhập bản dịch'),
            backgroundColor: AppColors.cardinal,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      userInput = _controller.text;
    } else {
      if (_selectedWords.isEmpty) {
        _shakeController.forward(from: 0);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vui lòng xếp các từ thành câu'),
            backgroundColor: AppColors.cardinal,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      userInput = _selectedWords.map((w) => w.text).join(' ');
    }

    setState(() {
      _isSubmitted = true;
      _isLoading = true;
    });

    final normalizedInput = normalize(userInput);
    final correctAnswer = normalize(_meta.correctAnswer);

    context.read<ExerciseBloc>().add(
      TranslateCheck(
        userAnswer: normalizedInput,
        sourceText: _meta.sourceText,
        correctAnswer: correctAnswer,
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
        _controller.clear();
        _selectedWords.clear();
        _initWordBank();
        _isSubmitted = false;
        _isLoading = false;
      });
    }
  }

  void _toggleMode() {
    setState(() {
      if (_mode == TranslateMode.keyboard) {
        _mode = TranslateMode.wordBank;
        _focusNode.unfocus();
      } else {
        _mode = TranslateMode.keyboard;
        if (_selectedWords.isNotEmpty) {
          _controller.text = _selectedWords.map((w) => w.text).join(' ');
        }
        _focusNode.requestFocus();
      }
    });
  }

  Future<void> _onWordTapBank(WordItem word) async {
    if (_isSubmitted || _animating.contains(word.id) || _selectedWords.contains(word)) return;
    HapticFeedback.lightImpact();

    final targetIndex = _selectedWords.length;
    _selectedSlotKeys[targetIndex] = GlobalKey();

    setState(() {
      _animating.add(word.id);
    });

    await Future.delayed(Duration.zero);
    await _animateTileMove(word, startKey: _bankPlaceholderKeys[word.id]!, endKey: _selectedSlotKeys[targetIndex]!, toSelected: true);

    setState(() {
      _selectedWords.add(word);
      _animating.remove(word.id);
      _selectedSlotKeys.remove(targetIndex);
    });
  }

  Future<void> _onWordTapSelected(WordItem word, int index) async {
    if (_isSubmitted || _animating.contains(word.id)) return;
    HapticFeedback.lightImpact();

    setState(() {
      _animating.add(word.id);
    });

    _selectedSlotKeys[index] ??= GlobalKey();

    await Future.delayed(Duration.zero);
    await _animateTileMove(word, startKey: _selectedSlotKeys[index]!, endKey: _bankPlaceholderKeys[word.id]!, toSelected: false);

    setState(() {
      _selectedWords.removeAt(index);
      _animating.remove(word.id);
    });
  }

  Future<void> _animateTileMove(WordItem word, {required GlobalKey startKey, required GlobalKey endKey, required bool toSelected}) async {
    final overlay = Overlay.of(context);
    if (startKey.currentContext == null || endKey.currentContext == null) return;

    final startBox = startKey.currentContext!.findRenderObject() as RenderBox;
    final endBox = endKey.currentContext!.findRenderObject() as RenderBox;
    final startPos = startBox.localToGlobal(Offset.zero);
    final endPos = endBox.localToGlobal(Offset.zero);
    final tileSize = startBox.size;

    final controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    final curved = CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return AnimatedBuilder(
          animation: curved,
          builder: (context, child) {
            final t = curved.value;
            final basePos = Offset.lerp(startPos, endPos, t)!;
            final lift = toSelected ? -30.0 * (4 * t * (1 - t)) : 0.0;
            final currentPos = basePos + Offset(0, lift);

            return Positioned(
              left: currentPos.dx,
              top: currentPos.dy,
              width: tileSize.width,
              height: tileSize.height,
              child: Material(
                color: Colors.transparent,
                child: ChoiceTile(text: word.text, state: ChoiceTileState.defaults, onPressed: () {}),
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

  Widget _buildInteractiveSourceText() {
    final words = _meta.sourceText.split(' ');
    return Wrap(
      spacing: 6.w,
      runSpacing: 4.h,
      children: words.map((w) {
        final displayWord = w;
        final cleanWord = w.replaceAll(RegExp(r'[^\w\s]'), '');
        return Tooltip(
          message: "Gợi ý: Dịch của từ '$cleanWord'",
          triggerMode: TooltipTriggerMode.tap,
          decoration: BoxDecoration(
            color: AppColors.wolf.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8.r),
          ),
          textStyle: TextStyle(color: Colors.white, fontSize: 14.sp),
          preferBelow: false,
          child: Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.hare, width: 2, style: BorderStyle.solid)),
            ),
            child: Text(
              displayWord,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: AppColors.bodyText),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseBloc, ExerciseState>(
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

            // Challenge header
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: CharacterChallenge(
                  challengeTitle: 'Dịch câu này',
                  challengeContent: _buildInteractiveSourceText(),
                  characterPosition: CharacterPosition.left,
                  variant: isCorrect == null ? SpeechBubbleVariant.neutral : (isCorrect ? SpeechBubbleVariant.correct : SpeechBubbleVariant.incorrect),
                ),
              ),
            ),
            
            SizedBox(height: 24.h),

            // Toggle mode button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _isSubmitted ? null : _toggleMode,
                  icon: Icon(_mode == TranslateMode.keyboard ? Icons.extension : Icons.keyboard, color: AppColors.macaw, size: 20.sp),
                  label: Text(_mode == TranslateMode.keyboard ? 'Dùng Xếp chữ' : 'Dùng Bàn phím', style: TextStyle(color: AppColors.macaw, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                ),
              ),
            ),

            // Input area
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value * ((_shakeController.value * 4).floor().isEven ? 1 : -1), 0),
                      child: child,
                    );
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _mode == TranslateMode.keyboard ? _buildKeyboardMode(isCorrect) : _buildWordBankMode(isCorrect),
                  ),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Action buttons
            if (isCorrect != null)
              ExerciseFeedback(
                isCorrect: isCorrect,
                onContinue: _handleContinue,
                correctAnswer: isCorrect ? null : _meta.correctAnswer,
                hint: isCorrect ? null : (_meta.hints?.isNotEmpty == true ? _meta.hints!.first : null),
              )
            else
              _buildCheckButton(),
          ],
        );
      },
    );
  }

  Widget _buildKeyboardMode(bool? isCorrect) {
    return FadeInUp(
      key: const ValueKey('keyboard_mode'),
      duration: const Duration(milliseconds: 400),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: 150.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.snow,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: (_isSubmitted && isCorrect != null) ? (isCorrect == true ? AppColors.primary : AppColors.cardinal) : AppColors.hare,
            width: 2,
          ),
          boxShadow: _isSubmitted && isCorrect != null ? [
            BoxShadow(color: (isCorrect ? AppColors.primary : AppColors.cardinal).withOpacity(0.2), blurRadius: 8, spreadRadius: 2),
          ] : [],
        ),
        child: Stack(
          children: [
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: !_isSubmitted,
              minLines: 4,
              maxLines: 10,
              style: TextStyle(color: AppColors.eel, fontSize: 18.sp, height: 1.5),
              decoration: InputDecoration(hintText: 'Nhập bản dịch của bạn...', hintStyle: TextStyle(color: AppColors.hare, fontSize: 18.sp), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
            ),
            if (!_isSubmitted && _controller.text.isNotEmpty)
              Positioned(
                right: 0,
                bottom: 0,
                child: IconButton(icon: Icon(Icons.clear, color: AppColors.wolf), onPressed: () { HapticFeedback.lightImpact(); _controller.clear(); }),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildWordBankMode(bool? isCorrect) {
    return FadeInUp(
      key: const ValueKey('wordbank_mode'),
      duration: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Lớp nền chứa các từ đã chọn
          Container(
            constraints: BoxConstraints(minHeight: 120.h),
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.snow,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: (_isSubmitted && isCorrect != null) ? (isCorrect == true ? AppColors.primary : AppColors.cardinal) : AppColors.hare,
                width: 2,
              ),
              boxShadow: _isSubmitted && isCorrect != null ? [
                BoxShadow(color: (isCorrect ? AppColors.primary : AppColors.cardinal).withOpacity(0.2), blurRadius: 8, spreadRadius: 2),
              ] : [],
            ),
            child: _selectedWords.isEmpty && !_isSubmitted
                ? Text('Nhấn vào các từ bên dưới để ghép câu...', style: TextStyle(color: AppColors.hare, fontSize: 16.sp))
                : Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      ..._selectedWords.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final w = entry.value;
                        final isAnimating = _animating.contains(w.id);

                        ChoiceTileState state = ChoiceTileState.defaults;
                        if (_isSubmitted && isCorrect != null) {
                          final correctWords = normalize(_meta.correctAnswer).split(' ');
                          if (idx < correctWords.length && normalize(w.text) == correctWords[idx]) {
                            state = ChoiceTileState.correct;
                          } else {
                            state = ChoiceTileState.incorrect;
                          }
                        }
                        
                        return KeyedSubtree(
                          key: _selectedSlotKeys.putIfAbsent(idx, () => GlobalKey()),
                          child: Opacity(
                            opacity: isAnimating ? 0.0 : 1.0,
                            child: ChoiceTile(
                              text: w.text,
                              state: state,
                              onPressed: _isSubmitted ? () {} : () => _onWordTapSelected(w, idx),
                            ),
                          ),
                        );
                      }),
                      // Phantom slots
                      ..._selectedSlotKeys.entries
                          .where((e) => e.key >= _selectedWords.length)
                          .map(
                            (e) => KeyedSubtree(
                              key: e.value,
                              child: Opacity(
                                opacity: 0.0,
                                child: ChoiceTile(text: '', state: ChoiceTileState.defaults, onPressed: () {}),
                              ),
                            ),
                          ),
                    ],
                  ),
          ),

          SizedBox(height: 24.h),

          // Kho từ vựng (Word bank)
          if (!_isSubmitted)
            Wrap(
              spacing: 8.w,
              runSpacing: 12.h,
              alignment: WrapAlignment.center,
              children: _allWordBank.map((w) {
                final isSelected = _selectedWords.contains(w);
                final isAnimating = _animating.contains(w.id);

                return KeyedSubtree(
                  key: _bankPlaceholderKeys[w.id]!,
                  child: Opacity(
                    opacity: (isSelected || isAnimating) ? 0.0 : 1.0,
                    child: IgnorePointer(
                      ignoring: isSelected || isAnimating,
                      child: ChoiceTile(
                        text: w.text,
                        state: ChoiceTileState.defaults,
                        onPressed: () => _onWordTapBank(w),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildCheckButton() {
    bool isDisabled = false;
    if (_mode == TranslateMode.keyboard) {
      isDisabled = _controller.text.trim().isEmpty;
    } else {
      isDisabled = _selectedWords.isEmpty;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: AppButton(
        label: 'KIỂM TRA',
        onPressed: _handleSubmit,
        isDisabled: isDisabled,
        isLoading: _isLoading,
        variant: ButtonVariant.primary,
        size: ButtonSize.medium,
      ),
    );
  }
}
