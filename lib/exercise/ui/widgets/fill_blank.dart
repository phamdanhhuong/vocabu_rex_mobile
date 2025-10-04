import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/custom_button.dart';

class FillBlank extends StatefulWidget {
  final FillBlankMetaEntity meta;
  final String prompt;
  final String exerciseId;
  const FillBlank({
    super.key,
    required this.meta,
    required this.prompt,
    required this.exerciseId,
  });

  @override
  State<FillBlank> createState() => _ListenChooseState();
}

class _ListenChooseState extends State<FillBlank> {
  bool isPlaying = false;
  bool isConfirmed = false;
  FillBlankMetaEntity get _meta => widget.meta;
  String get _exerciseId => widget.exerciseId;
  String get _prompt => widget.prompt;
  final _controller = TextEditingController();

  FlutterTts flutterTts = FlutterTts();

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(1.0);
    await flutterTts.setVolume(1.0);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<ExerciseBloc, ExerciseState>(
        builder: (context, state) {
          if (state is ExercisesLoaded) {
            final parts = _prompt.split("_____");
            return Column(
              children: [
                SizedBox(height: 40.h),
                // Header section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            parts[0],
                            style: TextStyle(
                              color: AppColors.textBlue,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            child: TextField(
                              controller: _controller,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textBlue,
                              ),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            parts.length > 1 ? parts[1] : "",
                            style: TextStyle(
                              color: AppColors.textBlue,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40.h),
                      if (_meta.hint != null)
                        Text(
                          "Hint: ${_meta.hint}",
                          style: TextStyle(
                            color: AppColors.primaryYellow,
                            fontSize: 20,
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
                Spacer(),
                // Confirm button (chỉ hiện khi chưa chọn đáp án)
                if (state.isCorrect == null)
                  CustomButton(
                    color: AppColors.primaryGreen,
                    onTap: () {
                      context.read<ExerciseBloc>().add(
                        AnswerSelected(
                          selectedAnswer: _controller.text.toLowerCase(),
                          correctAnswer: _meta.correctAnswer,
                          exerciseId: _exerciseId,
                        ),
                      );
                    },
                    label: "Xác nhận",
                  )
                else
                  SizedBox.shrink(),
              ],
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }

  // void _playPause(String word) async {
  //   if (isPlaying) {
  //     await _player.pause();
  //   } else {
  //     //await _player.play(UrlSource(convertToMp3Url(url))); // phát nhạc từ link
  //     if (word.isNotEmpty) {
  //       await speak(word);
  //     }
  //   }
  //   setState(() {
  //     isPlaying = !isPlaying;
  //   });
  // }
}
