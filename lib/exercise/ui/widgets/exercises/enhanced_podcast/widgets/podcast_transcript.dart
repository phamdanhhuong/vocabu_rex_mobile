import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/enhanced_podcast_meta_entity.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/typography.dart';

/// Transcript section showing all podcast segments
class PodcastTranscript extends StatelessWidget {
  final EnhancedPodcastMetaEntity meta;
  final int currentSegmentIndex;

  const PodcastTranscript({
    super.key,
    required this.meta,
    required this.currentSegmentIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (!meta.showTranscript) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: meta.segments.asMap().entries.map((entry) {
        final index = entry.key;
        final segment = entry.value;
        final isActive = index == currentSegmentIndex;
        final isPast = index < currentSegmentIndex;

        return Opacity(
          opacity: isPast ? 0.5 : 1.0,
          child: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.macaw.withOpacity(0.1)
                  : AppColors.polar,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isActive ? AppColors.macaw : Colors.transparent,
                width: 2.w,
              ),
            ),
            child: Text(
              '${index + 1}. ${segment.transcript}',
              style: AppTypography.defaultTextTheme().bodyMedium?.copyWith(
                    color: AppColors.eel,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
