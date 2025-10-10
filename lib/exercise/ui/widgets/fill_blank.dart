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
    return Expanded(
      child: BlocBuilder<ExerciseBloc, ExerciseState>(
        builder: (context, state) {
          if (state is ExercisesLoaded) {
            return Column(
              children: [
                SizedBox(height: 40.h),
                // Header section
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: _meta.sentences.length,
                    itemBuilder: (context, index) {
                      final sentence = _meta.sentences[index].text;
                      final parts = sentence.split("___");

                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Wrap(
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
                              child: _meta.sentences[index].options == null
                                  ? TextField(
                                      controller: _controllers[index],
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
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        // cho phép xóa lựa chọn (optional)
                                        setState(() {
                                          final current =
                                              _controllers[index].text;
                                          if (current.isNotEmpty) {
                                            remainingOptions.add(current);
                                            _controllers[index].clear();
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppColors.textBlue,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        width: 100,
                                        alignment: Alignment.center,
                                        child: Text(
                                          _controllers[index].text.isEmpty
                                              ? "..."
                                              : _controllers[index].text,
                                          style: TextStyle(
                                            color: AppColors.textBlue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                            if (parts.length > 1)
                              Text(
                                parts[1],
                                style: TextStyle(
                                  color: AppColors.textBlue,
                                  fontSize: 20,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 30.h),
                Spacer(),
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
                            color: AppColors.primaryGreen.withOpacity(0.1),
                            border: Border.all(color: AppColors.primaryGreen),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            word,
                            style: TextStyle(
                              color: AppColors.primaryGreen,
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
                    color: AppColors.primaryGreen,
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
      ),
    );
  }
}
