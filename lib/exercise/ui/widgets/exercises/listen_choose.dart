import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:vocabu_rex_mobile/theme/widgets/challenges/challenge.dart';
import 'package:vocabu_rex_mobile/theme/widgets/speech_bubbles/speech_bubble.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/exercises/listen_choose_select.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/exercises/listen_choose_type.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/exercises/widgets/audio_speaker_buttons.dart';

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
    Key? key,
    required this.meta,
    required this.exerciseId,
    this.onContinue,
  }) : super(key: key);

  @override
  State<ListenChoose> createState() => _ListenChooseState();
}

class _ListenChooseState extends State<ListenChoose> {
  late FlutterTts _tts;
  bool _isPlayingNormal = false;
  bool _isPlayingSlow = false;
  bool _revealed = false;
  bool _isSubmitted = false;
  late String _effectiveMode; // 'select' or 'type', randomized if needed
  
  // For select mode
  List<String> _selectedWords = [];
  late List<String> _availableWords;
  
  // For type mode
  final TextEditingController _typeController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _initTts();
    _determineMode();
    _generateAvailableWords();
  }

  void _initTts() async {
    await _tts.setLanguage("en-US");
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
    final correctWords = widget.meta.correctAnswer.split(' ');
    final sentenceWords = widget.meta.sentence.split(' ');
    final additionalWords = widget.meta.options;
    
    final allWords = <String>{
      ...correctWords,
      ...sentenceWords,
      ...additionalWords,
    }.toList();
    
    setState(() {
      _availableWords = allWords..shuffle();
    });
  }

  Future<void> _speakNormal() async {
    if (_isPlayingNormal || _isPlayingSlow) return;
    setState(() => _isPlayingNormal = true);
    
    await _tts.setSpeechRate(0.5);
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
    });
  }

  void _handleSubmit() {
    setState(() {
      _isSubmitted = true;
    });
    
    final userAnswer = _effectiveMode == 'select'
        ? _selectedWords.join(' ')
        : _typeController.text.trim();
    // Normalize answers: case-insensitive and ignore extra whitespace
    String normalize(String s) => s.replaceAll(RegExp(r"\s+"), ' ').trim().toLowerCase();

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

        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(height: 12.h),
            
            // Challenge header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: CharacterChallenge(
                challengeTitle: 'Nghe và điền đáp án',
                challengeContent: Text(
                  'Nhấn nút loa để nghe và điền đáp án',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                ),
                character: Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: Colors.blue[300],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.headphones, size: 40.sp, color: Colors.white),
                ),
                characterPosition: CharacterPosition.left,
                variant: isCorrect == null
                    ? SpeechBubbleVariant.neutral
                    : (isCorrect ? SpeechBubbleVariant.correct : SpeechBubbleVariant.incorrect),
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Speaker buttons row - new custom UI
            AudioSpeakerButtons(
              isPlayingNormal: _isPlayingNormal,
              isPlayingSlow: _isPlayingSlow,
              onPlayNormal: _speakNormal,
              onPlaySlow: _speakSlow,
            ),
            
            SizedBox(height: 24.h),
            
            // Input area (select or type mode) - using separate components
            Expanded(
              child: _effectiveMode == 'select'
                  ? ListenChooseSelectMode(
                      meta: widget.meta,
                      isSubmitted: _isSubmitted,
                      revealed: _revealed,
                      isCorrect: isCorrect,
                      selectedWords: _selectedWords,
                      availableWords: _availableWords,
                      onSelectWord: _handleSelectWord,
                      onUnselectWord: _handleUnselectWord,
                    )
                  : ListenChooseTypeMode(
                      controller: _typeController,
                      isSubmitted: _isSubmitted,
                      revealed: _revealed,
                      isCorrect: isCorrect,
                      correctAnswer: widget.meta.correctAnswer,
                    ),
            ),
            
            SizedBox(height: 16.h),
            
            // Action buttons
            _buildActionButtons(isCorrect),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons(bool? isCorrect) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: isCorrect != null
          ? Container(
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 12.w),
              decoration: BoxDecoration(
                color: isCorrect ? AppColors.correctGreenLight : AppColors.incorrectRedLight,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
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
                    label: 'TIẾP TỤC',
                    onPressed: _handleContinue,
                    variant: ButtonVariant.primary,
                    size: ButtonSize.medium,
                  ),
                ],
              ),
            )
          : Column(
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
                  variant: ButtonVariant.primary,
                  size: ButtonSize.medium,
                ),
              ],
            ),
    );
  }
}

