import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/enhanced_podcast_meta_entity.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

/// Media section for podcast player (top section)
class PodcastMediaSection extends StatelessWidget {
  final EnhancedPodcastMetaEntity meta;
  final bool isPlaying;
  final Animation<double> pulseAnimation;

  const PodcastMediaSection({
    super.key,
    required this.meta,
    required this.isPlaying,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    if (meta.media == null || meta.media!.type == PodcastMediaType.none) {
      return _buildDefaultMediaPlaceholder();
    }

    // TODO: Implement GIF, Video, Lottie players
    return _buildDefaultMediaPlaceholder();
  }

  Widget _buildDefaultMediaPlaceholder() {
    return Container(
      height: 200.h,
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.macaw.withOpacity(0.3),
            AppColors.primary.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: isPlaying ? pulseAnimation.value : 1.0,
              child: Icon(
                isPlaying ? Icons.graphic_eq : Icons.podcasts,
                size: 80.sp,
                color: AppColors.macaw,
              ),
            );
          },
        ),
      ),
    );
  }
}
