import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:record/record.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:vocabu_rex_mobile/theme/widgets/challenges/challenge.dart';
import 'package:vocabu_rex_mobile/theme/widgets/speech_bubbles/speech_bubble.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
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

  final audioPlayer = AudioPlayer();

  // For sound wave animation
  late AnimationController _waveController;
  final List<double> _waveHeights = List.generate(5, (_) => 0.3);
  
  // For mic button pulse animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  Future<void> _startRecording() async {
    try {
      if (await record.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final filePath = path.join(
          dir.path,
          'record_${DateTime.now().millisecondsSinceEpoch}.m4a',
        );

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
          _recordPath = filePath;
        });

        // Start wave animation
        _waveController.repeat(reverse: true);

        debugPrint('Bắt đầu ghi âm: $_recordPath');
      } else {
        debugPrint('Không có quyền ghi âm');
      }
    } catch (e) {
      debugPrint('Lỗi khi ghi âm: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await record.stop();

      // Stop wave animation
      _waveController.stop();

      setState(() {
        _isRecording = false;
        // Reset wave heights
        for (int i = 0; i < _waveHeights.length; i++) {
          _waveHeights[i] = 0.3;
        }
      });

      if (_recordPath != null && File(_recordPath!).existsSync()) {
        debugPrint('Ghi âm xong, file: $_recordPath');
        await audioPlayer.play(DeviceFileSource(_recordPath!));
        debugPrint('▶️ Đang phát lại ghi âm...');
      }
    } catch (e) {
      debugPrint('Lỗi khi dừng ghi âm: $e');
    }
  }

  void _handleSkip() {
    setState(() {
      _skipped = true;
      _isSubmitted = true;
    });
    // When skipped, mark as correct (auto pass)
    context.read<ExerciseBloc>().add(
      AnswerSelected(
        selectedAnswer: _meta.expectedText,
        correctAnswer: _meta.expectedText,
        exerciseId: _exerciseId,
      ),
    );
  }

  void _handleSubmit() {
    if (_recordPath == null || !File(_recordPath!).existsSync()) {
      debugPrint('Chưa có file ghi âm để kiểm tra');
      return;
    }

    setState(() {
      _isSubmitted = true;
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
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _waveController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 300),
        )..addListener(() {
          if (_isRecording) {
            setState(() {
              // Simulate audio waves bouncing
              for (int i = 0; i < _waveHeights.length; i++) {
                _waveHeights[i] =
                    0.2 +
                    (0.6 *
                        (0.5 +
                            0.5 *
                                (i % 2 == 0
                                    ? _waveController.value
                                    : 1 - _waveController.value)));
              }
            });
          }
        });
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant Speak oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only reset when moving to a new exercise
    if (oldWidget.exerciseId != widget.exerciseId) {
      setState(() {
        _isSubmitted = false;
        _skipped = false;
        _recordPath = null;
        _isRecording = false;
      });
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    record.dispose();
    audioPlayer.dispose();
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

            // Challenge header with speech bubble
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: CharacterChallenge(
                challengeTitle: 'Đọc câu này',
                challengeContent: Text(
                  _meta.prompt,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                character: Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: Colors.red[400],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, size: 40.sp, color: Colors.white),
                ),
                characterPosition: CharacterPosition.left,
                variant: isCorrect == null
                    ? SpeechBubbleVariant.neutral
                    : (isCorrect
                          ? SpeechBubbleVariant.correct
                          : SpeechBubbleVariant.incorrect),
              ),
            ),

            SizedBox(height: 32.h),

            // Microphone button (Duolingo style - rectangular with rounded corners)
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isRecording ? 1.0 : _pulseAnimation.value,
                      child: GestureDetector(
                        onLongPressStart: _isSubmitted
                            ? null
                            : (_) async => await _startRecording(),
                        onLongPressEnd: _isSubmitted
                            ? null
                            : (_) async => await _stopRecording(),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: _isRecording ? 320.w : 300.w,
                          height: 80.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            color: _isSubmitted ? Colors.grey[300] : Colors.white,
                            border: Border.all(
                              color: _isSubmitted
                                  ? Colors.grey[400]!
                                  : (_isRecording
                                        ? AppColors.macaw
                                        : AppColors.macaw),
                              width: 3,
                            ),
                            boxShadow: _isRecording
                                ? [
                                    BoxShadow(
                                      color: AppColors.macaw.withOpacity(0.3),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : [],
                          ),
                          child: _isRecording ? _buildSoundWave() : _buildMicPrompt(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Action buttons
            if (isCorrect != null)
              ExerciseFeedback(
                isCorrect: isCorrect,
                onContinue: _handleContinue,
                correctAnswer: _skipped ? null : (isCorrect ? null : _meta.expectedText),
                isSkipped: _skipped,
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
            label: 'TẠM THỜI KHÔNG NÓI ĐƯỢC',
            onPressed: _handleSkip,
            isDisabled: _skipped,
            variant: ButtonVariant.outline,
            size: ButtonSize.medium,
          ),
          SizedBox(height: 12.h),
          AppButton(
            label: 'KIỂM TRA',
            onPressed: _handleSubmit,
            isDisabled: _recordPath == null || _skipped,
            variant: ButtonVariant.primary,
            size: ButtonSize.medium,
          ),
        ],
      ),
    );
  }

  /// Build the mic icon with "NHẤN ĐỂ NÓI" text (when not recording)
  Widget _buildMicPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.mic, size: 32.sp, color: AppColors.macaw),
        SizedBox(width: 12.w),
        Text(
          'NHẤN ĐỂ NÓI',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.macaw,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  /// Build animated sound wave bars (when recording)
  Widget _buildSoundWave() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(5, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: 8.w,
          height: 40.h * _waveHeights[index],
          decoration: BoxDecoration(
            color: AppColors.macaw,
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
      }),
    );
  }
}
