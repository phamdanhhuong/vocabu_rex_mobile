import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';

class Translate extends StatefulWidget {
  final TranslateMetaEntity meta;
  final String exerciseId;
  const Translate({super.key, required this.meta, required this.exerciseId});

  @override
  State<Translate> createState() => _SpeakState();
}

class _SpeakState extends State<Translate> {
  TranslateMetaEntity get _meta => widget.meta;
  String get _exerciseId => widget.exerciseId;

  void handleSubmit() {
    context.read<ExerciseBloc>().add(
      AnswerSelected(
        selectedAnswer: "done",
        correctAnswer: "done",
        exerciseId: _exerciseId,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
                  "Dịch nghĩa câu sau: ${_meta.sourceText}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textBlue,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      minLines: 5, // tối thiểu 3 dòng
                      maxLines: 7, // có thể giãn tới 5 dòng khi gõ thêm
                      decoration: InputDecoration(
                        hintText: 'Nhập nội dung...',
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12), // bo góc
                          borderSide: BorderSide(
                            color: AppColors.borderGrey, // màu viền mặc định
                            width: 1.2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.borderGrey,
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primaryBlue, // viền khi focus
                            width: 1.5,
                          ),
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
