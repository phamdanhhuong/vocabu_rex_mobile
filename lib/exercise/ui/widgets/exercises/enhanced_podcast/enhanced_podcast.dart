import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/enhanced_podcast_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/podcast_question_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/exercises/podcast_question_widgets.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/typography.dart';
import 'podcast_controller.dart';
import 'widgets/podcast_media_section.dart';
import 'widgets/podcast_controls.dart';

/// Enhanced Podcast Exercise với UI mới
/// Layout: Media (top) | Questions (middle) | Controls (bottom)
/// 
/// Architecture:
/// - UI only in this file
/// - Business logic in PodcastController
/// - State management via PodcastState
class EnhancedPodcast extends StatefulWidget {
  final EnhancedPodcastMetaEntity meta;
  final String exerciseId;

  const EnhancedPodcast({
    super.key,
    required this.meta,
    required this.exerciseId,
  });

  @override
  State<EnhancedPodcast> createState() => _EnhancedPodcastState();
}

class _EnhancedPodcastState extends State<EnhancedPodcast>
    with SingleTickerProviderStateMixin {
  late PodcastController _controller;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Setup pulse animation for media section
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Initialize controller
    _controller = PodcastController(
      meta: widget.meta,
      tts: FlutterTts(),
      onComplete: _handleComplete,
    );

    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _handleComplete() {
    context.read<ExerciseBloc>().add(
          AnswerSelected(
            selectedAnswer: "completed",
            correctAnswer: "completed",
            exerciseId: widget.exerciseId,
          ),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseBloc, ExerciseState>(
      builder: (context, state) {
        if (state is! ExercisesLoaded) return const SizedBox.shrink();

        final podcastState = _controller.state;

        return Column(
          children: [
            // Media section (top) - always visible
            PodcastMediaSection(
              meta: widget.meta,
              isPlaying: podcastState.isPlaying,
              pulseAnimation: _pulseAnimation,
            ),

            SizedBox(height: 16.h),

            // Question section (middle) - scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    _buildTitleSection(),
                    SizedBox(height: 20.h),
                    
                    // Feedback message
                    if (podcastState.feedbackMessage != null)
                      _buildFeedback(
                        podcastState.feedbackMessage!,
                        podcastState.feedbackColor!,
                      ),
                    
                    // Question ONLY - no transcript during learning
                    if (podcastState.currentQuestion != null)
                      _buildQuestionWidget(podcastState.currentQuestion!),
                  ],
                ),
              ),
            ),

            // Controls section (bottom)
            PodcastControls(
              isPlaying: podcastState.isPlaying,
              onPlayPause: _controller.togglePlayPause,
              onSeekBackward: _controller.seekBackward,
              onSeekForward: _controller.seekForward,
            ),
          ],
        );
      },
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.meta.title,
          style: AppTypography.defaultTextTheme().headlineMedium?.copyWith(
                color: AppColors.eel,
                fontWeight: FontWeight.w700,
              ),
        ),
        if (widget.meta.description != null) ...[
          SizedBox(height: 8.h),
          Text(
            widget.meta.description!,
            style: AppTypography.defaultTextTheme().bodyMedium?.copyWith(
                  color: AppColors.wolf,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildFeedback(String message, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color,
          width: 2.w,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            color == AppColors.primary
                ? Icons.check_circle
                : Icons.error,
            color: color,
            size: 24.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            message,
            style: AppTypography.defaultTextTheme()
                .titleMedium
                ?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionWidget(PodcastQuestionEntity question) {
    switch (question.type) {
      case PodcastQuestionType.match:
        return PodcastMatchQuestionWidget(
          question: question as PodcastMatchQuestion,
          onAnswered: _controller.handleQuestionAnswered,
        );
      case PodcastQuestionType.trueFalse:
        return PodcastTrueFalseQuestionWidget(
          question: question as PodcastTrueFalseQuestion,
          onAnswered: _controller.handleQuestionAnswered,
        );
      case PodcastQuestionType.listenChoose:
        return PodcastListenChooseQuestionWidget(
          question: question as PodcastListenChooseQuestion,
          onAnswered: _controller.handleQuestionAnswered,
        );
      case PodcastQuestionType.multipleChoice:
        return PodcastMultipleChoiceQuestionWidget(
          question: question as PodcastMultipleChoiceQuestion,
          onAnswered: _controller.handleQuestionAnswered,
        );
    }
  }
}
