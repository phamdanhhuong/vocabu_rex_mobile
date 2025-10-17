import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/audio_button.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/custom_button.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/option.dart';

class ListenChoose extends StatefulWidget {
  final ListenChooseMetaEntity meta;
  final String exerciseId;
  const ListenChoose({super.key, required this.meta, required this.exerciseId});

  @override
  State<ListenChoose> createState() => _ListenChooseState();
}

class _ListenChooseState extends State<ListenChoose> {
  bool isPlaying = false;
  int selectedOptionIndex = 0;
  bool isConfirmed = false;
  ListenChooseMetaEntity get _meta => widget.meta;
  String get _exerciseId => widget.exerciseId;

  FlutterTts flutterTts = FlutterTts();

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.3);
    await flutterTts.speak(text);
  }

  void onSelect(int index) {
    setState(() {
      selectedOptionIndex = index;
    });
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      AudioButton(
                        onPressed: () => _playPause(_meta.sentence),
                        isPlaying: isPlaying,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Listen and choose\nthe correct answer',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textBlue,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),

                // Options list
                Expanded(
                  child: ListView.builder(
                    itemCount: _meta.options.length,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemBuilder: (context, index) {
                      return Option(
                        isSelected: selectedOptionIndex == index,
                        label: _meta.options[index],
                        index: index,
                        onSelect: onSelect,
                      );
                    },
                  ),
                ),

                // Confirm button (chỉ hiện khi chưa chọn đáp án)
                if (state.isCorrect == null)
                  CustomButton(
                    color: AppColors.primaryGreen,
                    onTap: () {
                      context.read<ExerciseBloc>().add(
                        AnswerSelected(
                          selectedAnswer: _meta.options[selectedOptionIndex],
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

  void _playPause(String word) async {
    if (isPlaying) {
    } else {
      if (word.isNotEmpty) {
        await speak(word);
      }
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }
}
