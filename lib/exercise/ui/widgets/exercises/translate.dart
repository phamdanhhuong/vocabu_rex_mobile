import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

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

  // Animation for text field feedback
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // TTS for Magic Hint
  late FlutterTts _tts;

  // Magic Hint Overlay State
  OverlayEntry? _hintOverlayEntry;
  String? _activeHintWord;

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

    _tts = FlutterTts();
    _setupTts();

    _initWordBank();
  }

  Future<void> _setupTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(AppPreferences().isVoiceSpeedNormal ? 0.8 : 0.4);
    await _tts.setVolume(1.0);
  }

  void _initWordBank() {
    final cleanAnswer = _meta.correctAnswer
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), '');
    final words =
        cleanAnswer.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    _allWordBank = words
        .asMap()
        .entries
        .map((e) => WordItem(id: 'wb_${e.key}_${e.value}', text: e.value))
        .toList()..shuffle();
  }

  @override
  void dispose() {
    _removeHintOverlay();
    _controller.dispose();
    _focusNode.dispose();
    _shakeController.dispose();
    _tts.stop();
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
    _removeHintOverlay();
    String userInput = "";
    if (_mode == TranslateMode.keyboard) {
      if (_controller.text.trim().isEmpty) {
        _shakeController.forward(from: 0);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Vui lòng nhập bản dịch'),
            backgroundColor: AppColors.cardinal,
            duration: const Duration(seconds: 2),
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
            content: const Text('Vui lòng xếp các từ thành câu'),
            backgroundColor: AppColors.cardinal,
            duration: const Duration(seconds: 2),
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
    _removeHintOverlay();
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

  void _onWordTapBank(WordItem word) {
    if (_isSubmitted || _selectedWords.contains(word)) return;
    HapticFeedback.lightImpact();

    setState(() {
      _selectedWords.add(word);
    });
  }

  void _onWordTapSelected(WordItem word) {
    if (_isSubmitted) return;
    HapticFeedback.lightImpact();

    setState(() {
      _selectedWords.remove(word);
    });
  }

  // Magic Hint Logic
  void _playWordAudio(String word) {
    final cleanWord = word.replaceAll(RegExp(r'[^\w\s]'), '');
    setState(() {
      _activeHintWord = word;
    });
    
    // Đọc từ vựng
    _tts.speak(cleanWord);
    HapticFeedback.mediumImpact();

    // Auto remove highlight after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _activeHintWord == word) {
        setState(() {
          _activeHintWord = null;
        });
      }
    });
  }

  void _removeHintOverlay() {
    // Kept for compatibility with other methods calling it
    if (_activeHintWord != null) {
      setState(() {
        _activeHintWord = null;
      });
    }
  }

  Widget _buildInteractiveSourceText() {
    final words = _meta.sourceText.split(' ');
    final isDark = AppPreferences().isDarkMode;

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      alignment: WrapAlignment.center,
      children: words.map((w) {
        final LayerLink link = LayerLink();
        final isActive = _activeHintWord == w;

        return CompositedTransformTarget(
          link: link,
          child: GestureDetector(
            onTap: () => _playWordAudio(w),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isActive ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Text(
                w,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: isActive 
                      ? AppColors.primary 
                      : (isDark ? AppColors.bodyText : AppColors.eel),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppPreferences().isDarkMode;

    return BlocBuilder<ExerciseBloc, ExerciseState>(
      builder: (context, state) {
        if (state is! ExercisesLoaded) return const SizedBox.shrink();

        final isCorrect = state.isCorrect;
        if (_isLoading && isCorrect != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _isLoading = false);
          });
        }

        return GestureDetector(
          onTap: () {
            _removeHintOverlay();
            if (_mode == TranslateMode.keyboard) _focusNode.unfocus();
          },
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: 12.h),

              // Glassmorphism Source Card
              FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 20.w),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.snow : AppColors.snow,
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(
                        color: isDark ? AppColors.swan : AppColors.polar,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black.withOpacity(0.2) : AppColors.hare.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "DỊCH CÂU SAU",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _buildInteractiveSourceText(),

                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Toggle mode button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _isSubmitted ? null : _toggleMode,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.swan : AppColors.polar,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: isDark ? AppColors.hare.withOpacity(0.3) : AppColors.swan),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _mode == TranslateMode.keyboard ? Icons.extension : Icons.keyboard,
                            color: AppColors.macaw,
                            size: 18.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            _mode == TranslateMode.keyboard ? 'Xếp chữ' : 'Bàn phím',
                            style: TextStyle(
                              color: AppColors.macaw,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Input area
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: AnimatedBuilder(
                    animation: _shakeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          _shakeAnimation.value * ((_shakeController.value * 4).floor().isEven ? 1 : -1),
                          0,
                        ),
                        child: child,
                      );
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _mode == TranslateMode.keyboard
                          ? _buildKeyboardMode(isCorrect)
                          : _buildWordBankMode(isCorrect),
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
                  hint: isCorrect
                      ? null
                      : (_meta.hints?.isNotEmpty == true ? _meta.hints!.first : null),
                )
              else
                _buildCheckButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKeyboardMode(bool? isCorrect) {
    final isDark = AppPreferences().isDarkMode;
    final isFocused = _focusNode.hasFocus;

    return FadeInUp(
      key: const ValueKey('keyboard_mode'),
      duration: const Duration(milliseconds: 400),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        constraints: BoxConstraints(minHeight: 180.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.snow : AppColors.snow,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: _isSubmitted
                ? (isCorrect == true ? AppColors.primary : AppColors.cardinal)
                : (isFocused ? AppColors.primary : (isDark ? AppColors.swan : AppColors.polar)),
            width: isFocused || _isSubmitted ? 2 : 2,
          ),
          boxShadow: [
            if (isFocused && !_isSubmitted)
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            if (_isSubmitted && isCorrect != null)
              BoxShadow(
                color: (isCorrect ? AppColors.primary : AppColors.cardinal).withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            if (!isFocused && !_isSubmitted)
              BoxShadow(
                color: isDark ? Colors.black.withOpacity(0.2) : AppColors.hare.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
          ],
        ),
        child: Stack(
          children: [
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: !_isSubmitted,
              minLines: 4,
              maxLines: 10,
              style: TextStyle(
                color: isDark ? AppColors.bodyText : AppColors.eel,
                fontSize: 20.sp,
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: 'Nhập bản dịch của bạn...',
                hintStyle: TextStyle(color: AppColors.hare, fontSize: 18.sp),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            if (!_isSubmitted && _controller.text.isNotEmpty)
              Positioned(
                right: 0,
                bottom: 0,
                child: IconButton(
                  icon: Icon(Icons.clear, color: AppColors.wolf),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _controller.clear();
                  },
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildWordBankMode(bool? isCorrect) {
    final isDark = AppPreferences().isDarkMode;

    return FadeInUp(
      key: const ValueKey('wordbank_mode'),
      duration: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Lớp nền chứa các từ đã chọn (Magnetic Drop Zone)
          Container(
            constraints: BoxConstraints(minHeight: 140.h),
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.snow : AppColors.snow,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: _isSubmitted
                    ? (isCorrect == true ? AppColors.primary : AppColors.cardinal)
                    : (isDark ? AppColors.swan : AppColors.polar),
                width: 2,
              ),
              boxShadow: [
                if (_isSubmitted && isCorrect != null)
                  BoxShadow(
                    color: (isCorrect ? AppColors.primary : AppColors.cardinal).withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                if (!_isSubmitted)
                  BoxShadow(
                    color: isDark ? Colors.black.withOpacity(0.2) : AppColors.hare.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
              ],
            ),
            child: _selectedWords.isEmpty && !_isSubmitted
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.dashboard_customize_outlined, size: 32.sp, color: AppColors.hare),
                        SizedBox(height: 8.h),
                        Text(
                          'Nhấn vào các từ bên dưới để ghép câu...',
                          style: TextStyle(color: AppColors.hare, fontSize: 16.sp),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : Wrap(
                    spacing: 12.w,
                    runSpacing: 12.h,
                    children: [
                      ..._selectedWords.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final w = entry.value;

                        ChoiceTileState state = ChoiceTileState.defaults;
                        if (_isSubmitted) {
                          final correctWords = normalize(_meta.correctAnswer).split(' ');
                          if (idx < correctWords.length && normalize(w.text) == correctWords[idx]) {
                            state = ChoiceTileState.correct;
                          } else {
                            state = ChoiceTileState.incorrect;
                          }
                        }

                        return BounceInDown(
                          key: ValueKey('sel_${w.id}'),
                          duration: const Duration(milliseconds: 400),
                          child: ChoiceTile(
                            text: w.text,
                            state: state,
                            onPressed: _isSubmitted ? () {} : () => _onWordTapSelected(w),
                          ),
                        );
                      }),
                      // Dashed slot for the next word
                      if (!_isSubmitted && _selectedWords.length < _allWordBank.length)
                        Container(
                          width: 60.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: AppColors.hare.withOpacity(0.5),
                              width: 2,
                              style: BorderStyle.solid, // Flutter doesn't have dashed border natively without package, so using solid with opacity
                            ),
                            color: isDark ? AppColors.eel.withOpacity(0.3) : AppColors.polar.withOpacity(0.5),
                          ),
                        ),
                    ],
                  ),
          ),

          SizedBox(height: 32.h),

          // Kho từ vựng (Word bank)
          if (!_isSubmitted)
            Wrap(
              spacing: 12.w,
              runSpacing: 16.h,
              alignment: WrapAlignment.center,
              children: _allWordBank.where((w) => !_selectedWords.contains(w)).map((w) {
                return ZoomIn(
                  key: ValueKey('bank_${w.id}'),
                  duration: const Duration(milliseconds: 300),
                  child: ChoiceTile(
                    text: w.text,
                    state: ChoiceTileState.defaults,
                    onPressed: () => _onWordTapBank(w),
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
