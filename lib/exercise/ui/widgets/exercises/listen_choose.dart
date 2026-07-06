import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../../core/utils/tts_helper.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:vocabu_rex_mobile/theme/widgets/challenges/challenge.dart';
import 'package:vocabu_rex_mobile/theme/widgets/speech_bubbles/speech_bubble.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/exercises/listen_choose_select.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/exercises/listen_choose_type.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/exercises/widgets/audio_speaker_buttons.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/exercise_feedback.dart';

/// Refactored ListenChoose exercise with:
/// - 2 speaker buttons (normal + slow with turtle icon) - custom UI like Duolingo
/// - 2 input modes: 'select' (tiles with flying animations) or 'type' (text input)
/// - Random mode if not specified
/// - Action buttons like match: "HIỆN KHÔNG NGHE ĐƯỢC", "KIỂM TRA", "TIẾP TỤC"
class ListenChoose extends StatefulWidget {
  final ListenChooseMetaEntity meta;
  final String exerciseId;
  final VoidCallback? onContinue;

  const ListenChoose({
    super.key,
    required this.meta,
    required this.exerciseId,
    this.onContinue,
  });

  @override
  State<ListenChoose> createState() => _ListenChooseState();
}

class _ListenChooseState extends State<ListenChoose>
    with TickerProviderStateMixin {
  late FlutterTts _tts;
  bool _isPlayingNormal = false;
  bool _isPlayingSlow = false;
  bool _revealed = false;
  bool _isSubmitted = false;
  bool _isLoading = false;
  late String _effectiveMode; // 'select' or 'type', randomized if needed

  // For select mode
  List<String> _selectedWords = [];
  late List<String> _availableWords;

  // For type mode
  final TextEditingController _typeController = TextEditingController();

  // Entry animations
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _initTts();
    _determineMode();
    _generateAvailableWords();
  }

  void _initTts() async {
    await TtsHelper.setDynamicVoice(_tts, 'female', locale: 'en-us');
    await _tts.setVolume(1.0);
  }

  /// Determine effective mode.
  /// If backend omits `meta.mode` (null), the client will randomly pick one.
  void _determineMode() {
    if (widget.meta.mode == null) {
      final random = math.Random();
      _effectiveMode = random.nextBool() ? 'select' : 'type';
    } else {
      _effectiveMode = widget.meta.mode!;
    }
  }

  /// Generate available word options from correctAnswer, sentence, and meta.options
  /// to avoid duplication and provide distractors
  void _generateAvailableWords() {
    setState(() {
      _availableWords = widget.meta.options.toList()..shuffle();
      if (!_availableWords.contains(widget.meta.correctAnswer)) {
        _availableWords.add(widget.meta.correctAnswer);
        _availableWords.shuffle();
      }
    });

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeIn));

    _entryController.forward();
  }

  Future<void> _speakNormal() async {
    if (_isPlayingNormal || _isPlayingSlow) return;
    setState(() => _isPlayingNormal = true);

    await _tts.setSpeechRate(AppPreferences().isVoiceSpeedNormal ? 0.5 : 0.3);
    await _tts.speak(widget.meta.sentence);

    // Simple delay for demo; in production use TTS completion callback
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() => _isPlayingNormal = false);
  }

  Future<void> _speakSlow() async {
    if (_isPlayingNormal || _isPlayingSlow) return;
    setState(() => _isPlayingSlow = true);

    await _tts.setSpeechRate(0.25); // Slower
    await _tts.speak(widget.meta.sentence);

    await Future.delayed(const Duration(seconds: 5));
    if (mounted) setState(() => _isPlayingSlow = false);
  }

  void _handleReveal() {
    setState(() {
      _revealed = true;
      if (_effectiveMode == 'select') {
        _selectedWords = widget.meta.correctAnswer.split(' ');
      } else {
        _typeController.text = widget.meta.correctAnswer;
      }
      _isLoading = true;
    });

    // Mark as correct when skipped (auto pass)
    context.read<ExerciseBloc>().add(
      AnswerSelected(
        selectedAnswer: widget.meta.correctAnswer,
        correctAnswer: widget.meta.correctAnswer,
        exerciseId: widget.exerciseId,
      ),
    );
  }

  void _handleSubmit() {
    setState(() {
      _isSubmitted = true;
      _isLoading = true;
    });

    final userAnswer = _effectiveMode == 'select'
        ? _selectedWords.join(' ')
        : _typeController.text.trim();
    // Normalize answers: case-insensitive and ignore extra whitespace
    String normalize(String s) =>
        s.replaceAll(RegExp(r"\s+"), ' ').trim().toLowerCase();

    final normalizedUser = normalize(userAnswer);
    final normalizedCorrect = normalize(widget.meta.correctAnswer);

    context.read<ExerciseBloc>().add(
      AnswerSelected(
        selectedAnswer: normalizedUser,
        correctAnswer: normalizedCorrect,
        exerciseId: widget.exerciseId,
      ),
    );
  }

  void _handleSelectWord(String word) {
    setState(() {
      _selectedWords.add(word);
    });
  }

  void _handleUnselectWord(int index) {
    setState(() {
      _selectedWords.removeAt(index);
    });
  }

  void _handleContinue() {
    context.read<ExerciseBloc>().add(AnswerClear());
    if (widget.onContinue != null) {
      widget.onContinue!();
    } else {
      setState(() {
        _selectedWords.clear();
        _typeController.clear();
        _isSubmitted = false;
        _revealed = false;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tts.stop();
    _typeController.dispose();
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
        if (_isLoading && isCorrect != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _isLoading = false);
          });
        }

        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(height: 12.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: CharacterChallenge(
                challengeTitle: 'Nghe và chọn đáp án đúng',
                challengeContent: AudioSpeakerButtons(
                  isPlayingNormal: _isPlayingNormal,
                  isPlayingSlow: _isPlayingSlow,
                  onPlayNormal: _speakNormal,
                  onPlaySlow: _speakSlow,
                ),
                characterPosition: CharacterPosition.left,
                variant: isCorrect == null ? SpeechBubbleVariant.neutral : (isCorrect ? SpeechBubbleVariant.correct : SpeechBubbleVariant.incorrect),
              ),
            ),

            SizedBox(height: 24.h),

            // Toggle mode button
            FadeIn(
              duration: const Duration(milliseconds: 800),
              delay: const Duration(milliseconds: 400),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Align(
                  alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _revealed || _isSubmitted ? null : () {
                    setState(() {
                      if (_effectiveMode == 'select') {
                        _effectiveMode = 'type';
                        if (_selectedWords.isNotEmpty && _typeController.text.isEmpty) {
                          _typeController.text = _selectedWords.join(' ') + ' ';
                        }
                      } else {
                        _effectiveMode = 'select';
                      }
                    });
                  },
                  icon: Icon(
                    _effectiveMode == 'select' ? Icons.keyboard_rounded : Icons.grid_view_rounded,
                    color: AppColors.macaw,
                    size: 20.sp,
                  ),
                  label: Text(
                    _effectiveMode == 'select' ? 'Dùng bàn phím' : 'Dùng từ có sẵn',
                    style: TextStyle(
                      color: AppColors.macaw,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ),

            // Input area (select or type mode) - using separate components
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _effectiveMode == 'select'
                    ? FadeInUp(
                        key: const ValueKey('select_mode'),
                        duration: const Duration(milliseconds: 400),
                        child: ListenChooseSelectMode(
                          meta: widget.meta,
                          isSubmitted: _isSubmitted,
                          revealed: _revealed,
                          isCorrect: isCorrect,
                          selectedWords: _selectedWords,
                          availableWords: _availableWords,
                          onSelectWord: _handleSelectWord,
                          onUnselectWord: _handleUnselectWord,
                        ),
                      )
                    : FadeInUp(
                        key: const ValueKey('type_mode'),
                        duration: const Duration(milliseconds: 400),
                        child: ListenChooseTypeMode(
                          controller: _typeController,
                          isSubmitted: _isSubmitted,
                          revealed: _revealed,
                          isCorrect: isCorrect,
                          correctAnswer: widget.meta.correctAnswer,
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
                correctAnswer: isCorrect ? null : widget.meta.correctAnswer,
                hint: _revealed ? 'Bạn đã xem gợi ý!' : null,
                isSkipped: _revealed,
              )
            else
              _buildCheckButtons(),
          ],
        );
      },
    );
  }

  Widget _buildCheckButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            label: 'HIỆN KHÔNG NGHE ĐƯỢC',
            onPressed: _handleReveal,
            isDisabled: _revealed,
            variant: ButtonVariant.outline,
            size: ButtonSize.medium,
          ),
          SizedBox(height: 12.h),
          AppButton(
            label: 'KIỂM TRA',
            onPressed: _handleSubmit,
            isDisabled: _effectiveMode == 'select'
                ? _selectedWords.isEmpty
                : _typeController.text.trim().isEmpty,
            isLoading: _isLoading,
            variant: ButtonVariant.primary,
            size: ButtonSize.medium,
          ),
        ],
      ),
    );
  }
}
