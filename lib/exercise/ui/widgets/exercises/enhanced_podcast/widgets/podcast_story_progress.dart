import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class PodcastStoryProgress extends StatelessWidget {
  final int totalSegments;
  final int currentSegmentIndex;
  final bool isPlaying;

  const PodcastStoryProgress({
    super.key,
    required this.totalSegments,
    required this.currentSegmentIndex,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    if (totalSegments <= 1) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        children: List.generate(totalSegments, (index) {
          double value = 0.0;
          Color bgColor = AppColors.hare.withOpacity(0.3);
          
          if (index < currentSegmentIndex) {
            value = 1.0;
          } else if (index == currentSegmentIndex) {
            bgColor = AppColors.primary.withOpacity(0.3);
          }

          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: index == currentSegmentIndex && isPlaying
                    ? LinearProgressIndicator(
                        backgroundColor: bgColor,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ) // Indeterminate
                    : LinearProgressIndicator(
                        value: value,
                        minHeight: 4.h,
                        backgroundColor: bgColor,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
