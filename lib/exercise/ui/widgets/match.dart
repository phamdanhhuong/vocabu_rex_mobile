import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';

class MatchExercise extends StatefulWidget {
  final MatchMetaEntity meta;
  final String exerciseId;
  const MatchExercise({
    super.key,
    required this.meta,
    required this.exerciseId,
  });

  @override
  State<MatchExercise> createState() => _MatchExerciseState();
}

class _MatchExerciseState extends State<MatchExercise> {
  MatchMetaEntity get _meta => widget.meta;
  String get _exerciseId => widget.exerciseId;

  late List<String> leftItems;
  late List<String> rightItems;
  String? selectedLeft;
  String? selectedRight;
  Set<String> matchedLeft = {};
  Set<String> matchedRight = {};

  FlutterTts flutterTts = FlutterTts();

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.3);
    await flutterTts.speak(text);
  }

  @override
  void initState() {
    super.initState();
    leftItems = _meta.pairs.map((p) => p.left).toList();
    rightItems = _meta.pairs.map((p) => p.right).toList()..shuffle();
  }

  void handleSelection(String item, bool isLeft) {
    setState(() {
      if (isLeft) {
        if (selectedLeft == item) {
          selectedLeft = null;
        } else {
          selectedLeft = item;
          _playPause(item);
        }
      } else {
        if (selectedRight == item) {
          selectedRight = null;
        } else {
          selectedRight = item;
        }
      }

      if (selectedLeft != null && selectedRight != null) {
        // kiểm tra đúng/sai
        final correctPair = widget.meta.pairs.firstWhere(
          (p) => p.left == selectedLeft && p.right == selectedRight,
          orElse: () => MatchPair(left: '', right: ''),
        );

        if (correctPair.left.isNotEmpty) {
          // đúng
          matchedLeft.add(selectedLeft!);
          matchedRight.add(selectedRight!);
        }

        // reset chọn
        selectedLeft = null;
        selectedRight = null;

        //nếu nối hết -> gửi sự kiện kết thúc
        if (matchedLeft.length == leftItems.length) {
          context.read<ExerciseBloc>().add(
            AnswerSelected(
              selectedAnswer: "done",
              correctAnswer: "done",
              exerciseId: _exerciseId,
            ),
          );
        }
      }
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
                Text(
                  'Nối từ tiếng Anh với nghĩa tiếng Việt tương ứng.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textBlue,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Cột trái
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: leftItems.map((item) {
                          final isMatched = matchedLeft.contains(item);
                          final isSelected = selectedLeft == item;
                          return _buildOptionButton(
                            text: item,
                            color: isMatched
                                ? AppColors.borderGreyDark
                                : isSelected
                                ? AppColors.primaryYellow
                                : AppColors.textBlue.withOpacity(0.1),
                            onTap: isMatched
                                ? null
                                : () => handleSelection(item, true),
                          );
                        }).toList(),
                      ),

                      // Cột phải
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: rightItems.map((item) {
                          final isMatched = matchedRight.contains(item);
                          final isSelected = selectedRight == item;
                          return _buildOptionButton(
                            text: item,
                            color: isMatched
                                ? AppColors.borderGreyDark
                                : isSelected
                                ? AppColors.primaryYellow
                                : AppColors.textBlue.withOpacity(0.1),
                            onTap: isMatched
                                ? null
                                : () => handleSelection(item, false),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                // Options list
              ],
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }

  void _playPause(String word) async {
    if (word.isNotEmpty) {
      await speak(word);
    }
  }

  Widget _buildOptionButton({
    required String text,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        width: 140.w,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.primaryGreen.withOpacity(0.5)),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textBlue,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
