import os

base_dir = r"c:\TLCN\vocabu_rex_mobile\lib\exercise\ui\widgets\exercises"
enhanced_dir = os.path.join(base_dir, "enhanced_podcast")
widgets_dir = os.path.join(enhanced_dir, "widgets")

# 1. podcast_story_progress.dart
story_progress_code = """import 'package:flutter/material.dart';
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
"""

with open(os.path.join(widgets_dir, "podcast_story_progress.dart"), 'w', encoding='utf-8') as f:
    f.write(story_progress_code)

# 2. podcast_media_section.dart
media_section_code = """import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/enhanced_podcast_meta_entity.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class PodcastMediaSection extends StatefulWidget {
  final EnhancedPodcastMetaEntity meta;
  final int currentSegmentIndex;
  final bool isPlaying;
  final Animation<double> pulseAnimation;
  final bool isCompact;

  const PodcastMediaSection({
    super.key,
    required this.meta,
    required this.currentSegmentIndex,
    required this.isPlaying,
    required this.pulseAnimation,
    required this.isCompact,
  });

  @override
  State<PodcastMediaSection> createState() => _PodcastMediaSectionState();
}

class _PodcastMediaSectionState extends State<PodcastMediaSection> with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  bool _showTranscript = false;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    if (widget.isPlaying && !widget.isCompact) {
      _spinController.repeat();
    }
  }

  @override
  void didUpdateWidget(PodcastMediaSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !widget.isCompact) {
      if (!_spinController.isAnimating) _spinController.repeat();
    } else {
      _spinController.stop();
    }
    
    if (oldWidget.currentSegmentIndex != widget.currentSegmentIndex) {
      _showTranscript = false;
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppPreferences().isDarkMode;
    final currentSegment = widget.currentSegmentIndex < widget.meta.segments.length 
        ? widget.meta.segments[widget.currentSegmentIndex] 
        : null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.fastOutSlowIn,
      height: widget.isCompact ? 100.h : (_showTranscript ? 320.h : 280.h),
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.eel : AppColors.snow,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: widget.isCompact ? [] : [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : AppColors.hare.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        border: Border.all(color: isDark ? AppColors.swan : AppColors.polar, width: 2),
      ),
      child: Stack(
        children: [
          // Mesh Gradient Background (ClipRRect)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22.r),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: widget.isCompact ? 0.3 : 0.8,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.macaw.withOpacity(isDark ? 0.2 : 0.1),
                        AppColors.primary.withOpacity(isDark ? 0.2 : 0.1),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          AnimatedAlign(
            duration: const Duration(milliseconds: 600),
            curve: Curves.fastOutSlowIn,
            alignment: widget.isCompact ? Alignment.centerLeft : Alignment.topCenter,
            child: Padding(
              padding: widget.isCompact ? EdgeInsets.all(16.w) : EdgeInsets.only(top: 32.h),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                width: widget.isCompact ? 64.w : 140.w,
                height: widget.isCompact ? 64.w : 140.w,
                child: AnimatedBuilder(
                  animation: _spinController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _spinController.value * 2 * math.pi,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.macaw,
                              AppColors.primary,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: widget.isCompact ? 8 : 20,
                              spreadRadius: widget.isCompact ? 2 : 5,
                            )
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: widget.isCompact ? 24.w : 50.w,
                            height: widget.isCompact ? 24.w : 50.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? AppColors.eel : AppColors.snow,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Dynamic Waveform (only when not compact and playing)
          if (!widget.isCompact)
            Positioned(
              top: 190.h,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: widget.isPlaying ? 1.0 : 0.3,
                child: SizedBox(
                  height: 40.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(25, (index) {
                      return AnimatedBuilder(
                        animation: widget.pulseAnimation,
                        builder: (context, child) {
                          // Faking waveform using sine wave and pulse
                          final height = 10.h + 30.h * math.max(0, math.sin(index * 0.5 + widget.pulseAnimation.value * math.pi * 4));
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 2.w),
                            width: 4.w,
                            height: widget.isPlaying ? height : 4.h,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),
              ),
            ),

          // Transcript Button & Overlay (Spotify Lyrics style)
          if (!widget.isCompact && currentSegment != null)
            Positioned(
              bottom: 16.h,
              right: 16.w,
              left: 16.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showTranscript = !_showTranscript;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.swan : AppColors.polar,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.closed_caption, size: 16.sp, color: AppColors.primary),
                          SizedBox(width: 4.w),
                          Text(
                            _showTranscript ? 'Hide' : 'Transcript',
                            style: TextStyle(fontSize: 12.sp, color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showTranscript) ...[
                    SizedBox(height: 12.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.polar.withOpacity(0.9) : AppColors.snow.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        currentSegment.transcript,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.bodyText,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ]
                ],
              ),
            ),
            
          // Compact mode Info
          if (widget.isCompact)
            Positioned(
              left: 100.w,
              right: 16.w,
              top: 0,
              bottom: 0,
              child: Center(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Question Time!",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.bodyText,
                            ),
                          ),
                          Text(
                            "Select the correct answer below",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.wolf,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: AppColors.wolf, size: 24.sp),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
"""

with open(os.path.join(widgets_dir, "podcast_media_section.dart"), 'w', encoding='utf-8') as f:
    f.write(media_section_code)

# 3. podcast_controls.dart
controls_code = """import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class PodcastControls extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onSeekBackward;

  const PodcastControls({
    super.key,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onSeekBackward,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppPreferences().isDarkMode;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.swan : AppColors.polar,
          borderRadius: BorderRadius.circular(40.r),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : AppColors.hare.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: isDark ? AppColors.swan.withOpacity(0.1) : Colors.white,
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Replay current segment
            _buildControlButton(
              icon: Icons.replay_10,
              onPressed: onSeekBackward,
              color: AppColors.wolf,
              isDark: isDark,
            ),

            SizedBox(width: 48.w),

            // Play/Pause
            _buildControlButton(
              icon: isPlaying ? Icons.pause : Icons.play_arrow,
              onPressed: onPlayPause,
              color: AppColors.primary,
              isMain: true,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    bool isMain = false,
    required bool isDark,
  }) {
    final size = isMain ? 56.w : 40.w;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isMain ? color : (isDark ? AppColors.eel : AppColors.snow),
          shape: BoxShape.circle,
          boxShadow: isMain
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: isDark ? Colors.black.withOpacity(0.2) : AppColors.hare.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Icon(
          icon,
          size: isMain ? 32.sp : 24.sp,
          color: isMain ? AppColors.snow : color,
        ),
      ),
    );
  }
}
"""

with open(os.path.join(widgets_dir, "podcast_controls.dart"), 'w', encoding='utf-8') as f:
    f.write(controls_code)

# 4. Update enhanced_podcast.dart
enhanced_file = os.path.join(enhanced_dir, "enhanced_podcast.dart")
with open(enhanced_file, 'r', encoding='utf-8') as f:
    enhanced_content = f.read()

# Add import
if "import 'widgets/podcast_story_progress.dart';" not in enhanced_content:
    enhanced_content = enhanced_content.replace("import 'widgets/podcast_controls.dart';", "import 'widgets/podcast_controls.dart';\nimport 'widgets/podcast_story_progress.dart';")

# Update build method Column
old_column = """        return Column(
          children: [
            // Media section (top) - always visible
            PodcastMediaSection(
              meta: widget.meta,
              isPlaying: podcastState.isPlaying,
              pulseAnimation: _pulseAnimation,
            ),"""

new_column = """        return Column(
          children: [
            // Story Progress
            PodcastStoryProgress(
              totalSegments: widget.meta.segments.length,
              currentSegmentIndex: podcastState.currentSegmentIndex,
              isPlaying: podcastState.isPlaying,
            ),

            // Media section (top) - always visible
            PodcastMediaSection(
              meta: widget.meta,
              currentSegmentIndex: podcastState.currentSegmentIndex,
              isPlaying: podcastState.isPlaying,
              pulseAnimation: _pulseAnimation,
              isCompact: podcastState.currentQuestion != null,
            ),"""

enhanced_content = enhanced_content.replace(old_column, new_column)

# Update buildTitleSection to not render title when question is shown (to save space)
old_title_section = """                    _buildTitleSection(),
                    SizedBox(height: 20.h),

                    // Feedback message"""

new_title_section = """                    if (podcastState.currentQuestion == null) _buildTitleSection(),
                    if (podcastState.currentQuestion == null) SizedBox(height: 20.h),

                    // Feedback message"""

enhanced_content = enhanced_content.replace(old_title_section, new_title_section)

with open(enhanced_file, 'w', encoding='utf-8') as f:
    f.write(enhanced_content)

print("Podcast core UI patched.")
