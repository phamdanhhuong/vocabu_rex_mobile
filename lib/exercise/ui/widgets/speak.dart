import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:record/record.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class Speak extends StatefulWidget {
  final SpeakMetaEntity meta;
  final String exerciseId;
  const Speak({super.key, required this.meta, required this.exerciseId});

  @override
  State<Speak> createState() => _SpeakState();
}

class _SpeakState extends State<Speak> {
  SpeakMetaEntity get _meta => widget.meta;
  String get _exerciseId => widget.exerciseId;

  final record = AudioRecorder();
  String? _recordPath;
  bool _isRecording = false;

  final audioPlayer = AudioPlayer();

  void handleSubmit() {
    context.read<ExerciseBloc>().add(
      AnswerSelected(
        selectedAnswer: "done",
        correctAnswer: "done",
        exerciseId: _exerciseId,
      ),
    );
  }

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
      setState(() => _isRecording = false);

      if (_recordPath != null && File(_recordPath!).existsSync()) {
        debugPrint('Ghi âm xong, file: $_recordPath');

        await audioPlayer.play(DeviceFileSource(_recordPath!));
        debugPrint('▶️ Đang phát lại ghi âm...');

        // TODO: Gửi file đi (nếu muốn upload)
        // await uploadAudio(_recordPath!);

        // Sau khi xử lý xong, ví dụ gửi kết quả bài tập
        // context.read<ExerciseBloc>().add(
        //   AnswerSelected(
        //     selectedAnswer: "done",
        //     correctAnswer: "done",
        //     exerciseId: _exerciseId,
        //   ),
        // );
      }
    } catch (e) {
      debugPrint('Lỗi khi dừng ghi âm: $e');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    record.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<ExerciseBloc, ExerciseState>(
        builder: (context, state) {
          if (state is ExercisesLoaded) {
            return Column(
              children: [
                SizedBox(height: 20.h),
                Text(
                  _meta.prompt,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textBlue,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onLongPressStart: (_) async => await _startRecording(),
                      onLongPressEnd: (_) async => await _stopRecording(),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 80,
                        margin: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 3,
                            color: AppColors.primaryBlue,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.mic,
                              color: _isRecording
                                  ? AppColors.primaryRed
                                  : AppColors.primaryBlue,
                            ),
                            Text(
                              _isRecording
                                  ? "Đang ghi âm..."
                                  : "Nhấn giữ để nói",
                              style: TextStyle(
                                color: _isRecording
                                    ? AppColors.characterRed
                                    : AppColors.textBlue,
                                fontSize: 25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}
