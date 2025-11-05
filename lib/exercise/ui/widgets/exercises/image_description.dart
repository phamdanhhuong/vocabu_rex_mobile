import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/custom_button.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/image_with_border.dart';

class ImageDescription extends StatefulWidget {
  final ImageDescriptionMetaEntity meta;
  final String exerciseId;
  const ImageDescription({
    super.key,
    required this.meta,
    required this.exerciseId,
  });

  @override
  State<ImageDescription> createState() => _ImageDescriptionState();
}

class _ImageDescriptionState extends State<ImageDescription> {
  ImageDescriptionMetaEntity get _meta => widget.meta;
  String get _exerciseId => widget.exerciseId;
  final _controller = TextEditingController();

  void handleSubmit() {
    if (_controller.text.isNotEmpty) {
      String expectResult = _meta.expectedResults;
      String userInput = _controller.text;
      context.read<ExerciseBloc>().add(
        DescriptionCheck(
          content: userInput,
          expectResult: expectResult,
          exerciseId: _exerciseId,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Không để trống!",
            style: TextStyle(color: AppColors.textWhite),
          ),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
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
                  "${_meta.prompt}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textBlue,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                NetworkImageWithBorder(imageUrl: _meta.imageUrl),
                Flexible(
                  fit: FlexFit.loose,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _controller,
                      minLines: 5, // tối thiểu 3 dòng
                      maxLines: 7, // có thể giãn tới 5 dòng khi gõ thêm
                      style: TextStyle(color: AppColors.textWhite),
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
                CustomButton(
                  color: AppColors.primaryGreen,
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
