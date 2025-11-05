import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/challenges/challenge.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/custom_button.dart';

class Translate extends StatefulWidget {
  final TranslateMetaEntity meta;
  final String exerciseId;
  const Translate({super.key, required this.meta, required this.exerciseId});

  @override
  State<Translate> createState() => _TranslateState();
}

class _TranslateState extends State<Translate> {
  TranslateMetaEntity get _meta => widget.meta;
  String get _exerciseId => widget.exerciseId;
  final _controller = TextEditingController();

  void handleSubmit() {
    if (_controller.text.isNotEmpty) {
      String correctAnswer = _meta.correctAnswer;
      String userInput = _controller.text;
      context.read<ExerciseBloc>().add(
        AnswerSelected(
          selectedAnswer: normalize(correctAnswer),
          correctAnswer: normalize(userInput),
          exerciseId: _exerciseId,
        ),
      );
        } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Không để trống!",
            style: TextStyle(color: AppColors.white),
          ),
          backgroundColor: AppColors.cardinal,
        ),
      );
    }
  }

  String normalize(String text) {
    return text
        .toLowerCase() // bỏ phân biệt hoa thường
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), '') // bỏ dấu câu
        .replaceAll(RegExp(r'\s+'), ' ') // gộp nhiều khoảng trắng
        .trim(); // bỏ khoảng trắng đầu/cuối
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
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
                Text(
                  "Dịch nghĩa câu sau: ${_meta.sourceText}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.humpback,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // Character + speech bubble challenge
                if (_meta.sourceText.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: CharacterChallenge(
                      statusText: null,
                      challengeTitle: '',
                      challengeContent: Text(
                        _meta.sourceText,
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

                // Large white answer card with an internal TextField
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      color: AppColors.snow,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.hare.withOpacity(0.7)),
                    ),
                    child: TextField(
                      controller: _controller,
                      minLines: 3,
                      maxLines: 7,
                      style: TextStyle(color: AppColors.humpback, fontSize: 18.sp),
                      decoration: InputDecoration(
                        hintText: 'Nhập bản dịch...',
                        hintStyle: TextStyle(color: AppColors.hare),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                CustomButton(
                  color: AppColors.primary,
                  onTap: handleSubmit,
                  label: "Xác nhận",
                ),
              ],
            );
        }
        return SizedBox.shrink();
      },
    );
  }
}
