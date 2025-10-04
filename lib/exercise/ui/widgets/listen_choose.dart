import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/audio_button.dart';
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
  final AudioPlayer _player = AudioPlayer();

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
                        onPressed: () => _playPause(_meta.audioUrl),
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
                  GestureDetector(
                    onTap: () {
                      context.read<ExerciseBloc>().add(
                        AnswerSelected(
                          selectedAnswer: _meta.options[selectedOptionIndex],
                          correctAnswer: _meta.correctAnswer,
                          exerciseId: _exerciseId,
                        ),
                      );
                    },
                    child: Container(
                      height: 50.h,
                      margin: EdgeInsets.symmetric(
                        vertical: 8.h,
                        horizontal: 16.w,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.all(Radius.circular(18.r)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "Xác nhận",
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
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

  void _playPause(String url) async {
    if (isPlaying) {
      await _player.pause();
    } else {
      await _player.play(UrlSource(convertToMp3Url(url))); // phát nhạc từ link
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  String convertToMp3Url(String phpUrl) {
    Uri uri = Uri.parse(phpUrl);
    // Lấy param "id"
    String? id = uri.queryParameters["id"];
    if (id == null || id.isEmpty) {
      throw Exception("Thiếu tham số id trong url");
    }
    // Tạo url mp3
    final result =
        "${uri.scheme}://${uri.host}/${uri.pathSegments.take(uri.pathSegments.length - 1).join('/')}/audio/$id.mp3";
    return result;
  }
}
