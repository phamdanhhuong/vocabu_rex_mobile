import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/audio_button.dart';

class ListenChoose extends StatefulWidget {
  final ListenChooseMetaEntity meta;
  const ListenChoose({super.key, required this.meta});

  @override
  State<ListenChoose> createState() => _ListenChooseState();
}

class _ListenChooseState extends State<ListenChoose> {
  bool isPlaying = false;
  int selectedOptionIndex = 0;
  ListenChooseMetaEntity get _meta => widget.meta;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(height: 40.h),
          // Header section with audio button and instruction text
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                AudioButton(onPressed: _playAudio, isPlaying: isPlaying),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _playAudio() {
    setState(() {
      isPlaying = !isPlaying;
    });

    // TODO: Implement actual audio playback logic here
    // You can use packages like audioplayers or just_audio
    print('Playing audio for listen choose exercise');

    // Simulate audio playing for demo
    if (isPlaying) {
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            isPlaying = false;
          });
        }
      });
    }
  }
}

class Option extends StatelessWidget {
  final String label;
  final bool isSelected;

  const Option({super.key, required this.isSelected, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 50.h,
        margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.transparent,
          borderRadius: BorderRadius.all(Radius.circular(18.r)),
          border: isSelected
              ? Border.all(color: AppColors.primaryBlue, width: 3)
              : Border.all(color: AppColors.borderGrey),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: AppColors.characterBlue, fontSize: 16.sp),
          ),
        ),
      ),
    );
  }
}
