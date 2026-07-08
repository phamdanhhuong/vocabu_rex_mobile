import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:record/record.dart';
import 'package:animate_do/animate_do.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:vocabu_rex_mobile/theme/widgets/challenges/challenge.dart';
import 'package:vocabu_rex_mobile/theme/widgets/speech_bubbles/speech_bubble.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/exercise_feedback.dart';

class Speak extends StatefulWidget {
  final SpeakMetaEntity meta;
  final String exerciseId;
  final VoidCallback? onContinue;

  const Speak({
    super.key,
    required this.meta,
    required this.exerciseId,
    this.onContinue,
  });

  @override
  State<Speak> createState() => _SpeakState();
}

class _SpeakState extends State<Speak> with TickerProviderStateMixin {
  SpeakMetaEntity get _meta => widget.meta;
  String get _exerciseId => widget.exerciseId;

  final record = AudioRecorder();
  String? _recordPath;
  bool _isRecording = false;
  bool _isSubmitted = false;
  bool _skipped = false;
  bool _isLoading = false;

  final audioPlayer = AudioPlayer();

  // Animation controllers
  late AnimationController _rippleController;
  late AnimationController _karaokeController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    // Đủ dài để người dùng nói xong 1 câu trung bình
    _karaokeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _karaokeController.dispose();
    _shakeController.dispose();
    record.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (_isSubmitted || _isRecording) return;
    HapticFeedback.heavyImpact();

    try {
      if (await record.hasPermission()) {
        String filePath = '';
        if (!kIsWeb) {
          final dir = await getTemporaryDirectory();
          filePath = path.join(
            dir.path,
            'record_${DateTime.now().millisecondsSinceEpoch}.m4a',
          );
        }

        await record.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: filePath,
        );

        setState(() {
          _isRecording = true;
          if (!kIsWeb) {
            _recordPath = filePath;
          }
        });

        // Start animations
        _rippleController.repeat();
        _karaokeController.forward(from: 0).then((_) {
          if (_isRecording) _karaokeController.repeat();
        });
      }
    } catch (e) {
      debugPrint('Lỗi khi ghi âm: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    HapticFeedback.lightImpact();

    try {
      final outputPath = await record.stop();

      setState(() {
        _isRecording = false;
        if (outputPath != null) {
          _recordPath = outputPath;
        }
      });
      _rippleController.stop();
      _rippleController.reset();
      _karaokeController.stop();

      if (_recordPath != null) {
        if (kIsWeb || File(_recordPath!).existsSync()) {
          // Auto submit when release!
          _handleSubmit();
        }
      }
    } catch (e) {
      debugPrint('Lỗi khi dừng ghi âm: $e');
    }
  }

  void _handleSkip() {
    setState(() {
      _skipped = true;
      _isSubmitted = true;
      _isLoading = true;
    });
    context.read<ExerciseBloc>().add(
      AnswerSelected(
        selectedAnswer: _meta.expectedText,
        correctAnswer: _meta.expectedText,
        exerciseId: _exerciseId,
      ),
    );
  }

  void _handleSubmit() {
    if (_recordPath == null) return;
    if (!kIsWeb && !File(_recordPath!).existsSync()) return;

    setState(() {
      _isSubmitted = true;
      _isLoading = true;
    });

    context.read<ExerciseBloc>().add(
      SpeakCheck(
        path: _recordPath!,
        referenceText: _meta.expectedText,
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
        _recordPath = null;
        _isSubmitted = false;
        _skipped = false;
        _isLoading = false;
      });
    }
  }

  Widget _buildKaraokePrompt(bool? isCorrect) {
    final words = _meta.prompt.split(' ');
    return AnimatedBuilder(
      animation: _karaokeController,
      builder: (context, child) {
        final activeIndex = (_karaokeController.value * words.length * 1.2).floor();

        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 6.w,
          runSpacing: 4.h,
          children: words.asMap().entries.map((entry) {
            final idx = entry.key;
            final w = entry.value;
            final isActive = _isRecording && idx == activeIndex;
            final isPast = _isRecording && idx < activeIndex;

            Color wordColor;
            
            if (isActive) {
              wordColor = AppColors.primary;
            } else if (isPast) {
              wordColor = AppColors.primary.withValues(alpha: 0.6);
            } else if (_isSubmitted && isCorrect != null) {
              wordColor = isCorrect ? Colors.green[900]! : Colors.red[900]!;
            } else {
              wordColor = AppColors.eel; // Automatically handles dark/light mode
            }

            return AnimatedScale(
              scale: isActive ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                w,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  color: wordColor,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildWalkieTalkieButton() {
    return Listener(
      onPointerDown: (_) => _startRecording(),
      onPointerUp: (_) => _stopRecording(),
      onPointerCancel: (_) => _stopRecording(),
      child: AnimatedBuilder(
        animation: _rippleController,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Ripple 1
              if (_isRecording)
                Transform.scale(
                  scale: 1.0 + (_rippleController.value * 0.5),
                  child: Opacity(
                    opacity: 1.0 - _rippleController.value,
                    child: Container(
                      width: 150.w,
                      height: 150.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.macaw.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
              // Ripple 2
              if (_isRecording)
                Transform.scale(
                  scale: 1.0 + ((_rippleController.value + 0.5) % 1.0 * 0.5),
                  child: Opacity(
                    opacity: 1.0 - ((_rippleController.value + 0.5) % 1.0),
                    child: Container(
                      width: 150.w,
                      height: 150.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.macaw.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              // Main Button
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: _isRecording ? 120.w : 140.w,
                height: _isRecording ? 120.w : 140.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording ? AppColors.macaw : AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: (_isRecording ? AppColors.macaw : AppColors.primary).withOpacity(0.4),
                      blurRadius: _isRecording ? 20 : 10,
                      spreadRadius: _isRecording ? 5 : 2,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  _isRecording ? Icons.settings_voice : Icons.mic,
                  color: Colors.white,
                  size: 60.sp,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExerciseBloc, ExerciseState>(
      listener: (context, state) {
        if (state is ExercisesLoaded && _isSubmitted && state.isCorrect == false) {
          _shakeController.forward(from: 0);
          HapticFeedback.heavyImpact();
        }
      },
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

            // Prompt Area (Karaoke style)
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_shakeAnimation.value * ((_shakeController.value * 4).floor().isEven ? 1 : -1), 0),
                  child: child,
                );
              },
              child: FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: CharacterChallenge(
                    challengeTitle: 'Đọc to câu này',
                    characterPosition: CharacterPosition.left,
                    variant: isCorrect == null ? SpeechBubbleVariant.neutral : (isCorrect ? SpeechBubbleVariant.correct : SpeechBubbleVariant.incorrect),
                    challengeContent: Column(
                      children: [
                        Pulse(
                          infinite: true,
                          animate: _isRecording,
                          child: Icon(
                            _isRecording ? Icons.settings_voice : Icons.record_voice_over, 
                            color: _isRecording ? AppColors.macaw : AppColors.wolf, 
                            size: 36.sp
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _buildKaraokePrompt(isCorrect),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 40.h),

            // Microphone Area
            Expanded(
              child: Center(
                child: _isSubmitted
                    ? (isCorrect != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isCorrect ? Icons.check_circle : Icons.error,
                                color: isCorrect ? AppColors.primary : AppColors.cardinal,
                                size: 80.sp,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                isCorrect ? 'Phát âm tuyệt vời!' : 'Cần cố gắng thêm',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isCorrect ? AppColors.primary : AppColors.cardinal,
                                ),
                              )
                            ],
                          )
                        : CircularProgressIndicator(color: AppColors.primary))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildWalkieTalkieButton(),
                          SizedBox(height: 24.h),
                          Text(
                            _isRecording ? 'Đang lắng nghe...' : 'CHẠM & GIỮ ĐỂ NÓI',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: _isRecording ? AppColors.macaw : AppColors.wolf,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            // Action buttons
            if (isCorrect != null)
              ExerciseFeedback(
                isCorrect: isCorrect,
                onContinue: _handleContinue,
                correctAnswer: _skipped ? null : (isCorrect ? null : _meta.expectedText),
                isSkipped: _skipped,
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: AppButton(
                  label: 'TẠM THỜI KHÔNG NÓI ĐƯỢC',
                  onPressed: _isSubmitted ? () {} : _handleSkip,
                  isDisabled: _isSubmitted,
                  variant: ButtonVariant.outline,
                  size: ButtonSize.medium,
                  width: double.infinity,
                ),
              ),
          ],
        );
      },
    );
  }
}
