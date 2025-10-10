import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/custom_button.dart';

class MultipleChoice extends StatefulWidget {
  final MultipleChoiceMetaEntity meta;
  final String exerciseId;
  const MultipleChoice({
    super.key,
    required this.meta,
    required this.exerciseId,
  });

  @override
  State<MultipleChoice> createState() => _MultipleChoiceState();
}

class _MultipleChoiceState extends State<MultipleChoice> {
  MultipleChoiceMetaEntity get _meta => widget.meta;
  String get _exerciseId => widget.exerciseId;

  List<MultipleChoiceOption> selectedOrder = [];
  List<MultipleChoiceOption> shuffledOptions = [];

  @override
  void initState() {
    shuffledOptions = _meta.options..shuffle();
    super.initState();
  }

  void handleSubmit() {
    List<int> order = selectedOrder.map((option) {
      return option.order;
    }).toList();
    bool isCorrect = true;

    if (order.length == _meta.correctOrder.length) {
      for (int i = 0; i < order.length; i++) {
        if (order[i] != _meta.correctOrder[i]) {
          isCorrect = false;
        }
      }
    } else {
      isCorrect = false;
    }

    context.read<ExerciseBloc>().add(
      AnswerSelected(
        selectedAnswer: isCorrect ? "done" : "",
        correctAnswer: "done",
        exerciseId: _exerciseId,
      ),
    );
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
                  _meta.question,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textBlue,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: selectedOrder.map((option) {
                    return _buildOptionButton(
                      text: option.text,
                      color: Colors.transparent,
                      onTap: () {
                        setState(() {
                          shuffledOptions.add(option);
                          selectedOrder.remove(option);
                        });
                      },
                    );
                  }).toList(),
                ),
                Spacer(),
                // Options list
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: shuffledOptions.map((option) {
                    return _buildOptionButton(
                      text: option.text,
                      color: Colors.transparent,
                      onTap: () {
                        setState(() {
                          if (_meta.correctOrder.length !=
                              selectedOrder.length) {
                            selectedOrder.add(option);
                            shuffledOptions.remove(option);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                if (state.isCorrect == null)
                  if (selectedOrder.isNotEmpty)
                    CustomButton(
                      color: AppColors.primaryGreen,
                      onTap: handleSubmit,
                      label: "Xác nhận",
                    )
                  else
                    SizedBox.shrink()
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

  Widget _buildOptionButton({
    required String text,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: IntrinsicWidth(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 8.h),
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.primaryBlue),
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
      ),
    );
  }
}
