import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/custom_button.dart';
import 'package:vocabu_rex_mobile/theme/widgets/challenges/challenge.dart';

class FillBlank extends StatefulWidget {
  final FillBlankMetaEntity meta;
  final String exerciseId;
  const FillBlank({super.key, required this.meta, required this.exerciseId});

  @override
  State<FillBlank> createState() => _ListenChooseState();
}

class _ListenChooseState extends State<FillBlank> {
  bool isPlaying = false;
  bool isConfirmed = false;
  FillBlankMetaEntity get _meta => widget.meta;
  String get _exerciseId => widget.exerciseId;
  final List<TextEditingController> _controllers = [];
  final Set<String> remainingOptions = <String>{};
  final List<String> correctAnswers = [];

  FlutterTts flutterTts = FlutterTts();

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(1.0);
    await flutterTts.setVolume(1.0);
    await flutterTts.speak(text);
  }

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.meta.sentences.length; i++) {
      _controllers.add(TextEditingController());
      final sentence = widget.meta.sentences[i];
      if (sentence.options != null) {
        sentence.options!.forEach((option) {
          remainingOptions.add(option);
        });
        correctAnswers.add(sentence.correctAnswer);
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseBloc, ExerciseState>(
      builder: (context, state) {
        if (state is ExercisesLoaded) {
          return Column(
              children: [
                SizedBox(height: 20.h),
                // Character + speech bubble challenge (uses shared layout)
                if (_meta.context != null && _meta.context!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: CharacterChallenge(
                      statusText: null,
                      challengeTitle: '',
                      challengeContent: Text(
                        _meta.context!,
                        style: TextStyle(color: AppColors.humpback, fontSize: 16.sp),
                      ),
                      character: SizedBox(
                        width: 64.w,
                        child: CircleAvatar(
                          radius: 28.r,
                          backgroundColor: AppColors.beetle.withOpacity(0.12),
                          child: Icon(Icons.person, color: AppColors.humpback),
                        ),
                      ),
                      characterPosition: CharacterPosition.left,
                    ),
                  ),

                SizedBox(height: 16.h),

                // Large white card that contains the sentence(s) with blanks
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.hare.withOpacity(0.4)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(_meta.sentences.length, (index) {
                        final sentence = _meta.sentences[index].text;
                        final parts = sentence.split("___");
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Left part
                              Flexible(
                                child: Text(
                                  parts[0],
                                  style: TextStyle(
                                    color: AppColors.humpback,
                                    fontSize: 20.sp,
                                  ),
                                ),
                              ),

                              // Blank area (underlined)
                              GestureDetector(
                                onTap: () {
                                  // allow clearing the chosen option
                                  setState(() {
                                    final current = _controllers[index].text;
                                    if (current.isNotEmpty) {
                                      remainingOptions.add(current);
                                      _controllers[index].clear();
                                    }
                                  });
                                },
                                child: Container(
                                  width: 140.w,
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: AppColors.hare, width: 2),
                                    ),
                                  ),
                                  child: Text(
                                    _controllers[index].text.isEmpty
                                        ? ''
                                        : _controllers[index].text,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.humpback,
                                      fontSize: 20.sp,
                                    ),
                                  ),
                                ),
                              ),

                              // Right part (if exists)
                              if (parts.length > 1)
                                Flexible(
                                  child: Text(
                                    parts[1],
                                    style: TextStyle(
                                      color: AppColors.humpback,
                                      fontSize: 20.sp,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                if (remainingOptions.length > 0)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: remainingOptions.map((word) {
                      return GestureDetector(
                        onTap: () {
                          for (TextEditingController c in _controllers) {
                            if (c.text.isEmpty) {
                              setState(() {
                                c.text = word;
                                remainingOptions.remove(word);
                              });
                              return;
                            }
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            border: Border.all(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            word,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                SizedBox(height: 30.h),
                // Confirm button (chỉ hiện khi chưa chọn đáp án)
                if (state.isCorrect == null)
                  CustomButton(
                    color: AppColors.primary,
                    onTap: () {
                      List<String> listAnswer = <String>[];
                      for (TextEditingController c in _controllers) {
                        if (c.text.isNotEmpty) {
                          listAnswer.add(c.text);
                        }
                      }
                      if (listAnswer.length != correctAnswers.length) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Vui lòng điền đầy đủ tất cả đáp án'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }
                      context.read<ExerciseBloc>().add(
                        FilledBlank(
                          listAnswer: listAnswer,
                          listCorrectAnswer: correctAnswers,
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
    );
  }
}
