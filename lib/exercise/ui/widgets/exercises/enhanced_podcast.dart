// ============================================================================
// REFACTORED: Enhanced Podcast Widget
// ============================================================================
// This file has been refactored for better maintainability.
// All implementation moved to: enhanced_podcast/ folder
//
// Structure:
// - enhanced_podcast/enhanced_podcast.dart       (Main UI widget)
// - enhanced_podcast/podcast_controller.dart     (Business logic + TTS)
// - enhanced_podcast/podcast_state.dart          (State management)
// - enhanced_podcast/widgets/                    (Reusable UI components)
//
// Benefits:
// ✓ Separation of concerns (UI vs Logic)
// ✓ Easier to test individual components
// ✓ Easier to debug and maintain
// ✓ Reusable widgets
// ============================================================================

export 'enhanced_podcast/enhanced_podcast.dart';

// DEPRECATED: Old implementation below (kept for reference, will be removed later)
// TODO: Remove after confirming refactored version works correctly

/*
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/typography.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/enhanced_podcast_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/podcast_question_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'podcast_question_widgets.dart';

/// Enhanced Podcast Exercise với UI mới
/// Layout: Media (top) | Questions (middle) | Controls (bottom)
class EnhancedPodcastOLD extends StatefulWidget {
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
  EnhancedPodcastMetaEntity get _meta => widget.meta;
  String get _exerciseId => widget.exerciseId;

  late FlutterTts _tts;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _isPlaying = false;
  bool _isPaused = false;
  int _currentSegmentIndex = 0;
  PodcastQuestionEntity? _currentQuestion;
  double _currentPosition = 0.0; // seconds
  double _totalDuration = 0.0; // seconds
  String? _currentVoiceGender; // Track current voice to avoid unnecessary changes
  
  // Track which segments have already shown their questions
  Set<int> _segmentsWithQuestionsShown = {};
  
  // Feedback state
  String? _feedbackMessage;
  Color? _feedbackColor;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _setupTts();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _estimateDuration();
    _startPlayback();
  }

  Future<void> _setupTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(500);
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);

    _tts.setCompletionHandler(() {
      print('🔔 TTS Completion Handler called');
      if (mounted) {
        _onSegmentComplete();
      } else {
        print('⚠️ Widget not mounted, skipping');
      }
    });

    _tts.setProgressHandler((text, start, end, word) {
      if (mounted) {
        setState(() {
          // Update progress based on TTS progress
          final segmentDuration = _estimateSegmentDuration(_currentSegmentIndex);
          _currentPosition = _getSegmentStartTime(_currentSegmentIndex) +
              (end / text.length) * segmentDuration;
        });
      }
    });
  }

  void _estimateDuration() {
    double total = 0;
    for (var segment in _meta.segments) {
      // Estimate: ~150 words per minute = 2.5 words per second
      final words = segment.transcript.split(' ').length;
      total += words / 2.5;
    }
    _totalDuration = total;
  }

  double _estimateSegmentDuration(int index) {
    if (index >= _meta.segments.length) return 0;
    final words = _meta.segments[index].transcript.split(' ').length;
    return words / 2.5;
  }

  double _getSegmentStartTime(int index) {
    double time = 0;
    for (int i = 0; i < index && i < _meta.segments.length; i++) {
      time += _estimateSegmentDuration(i);
    }
    return time;
  }

  Future<void> _setVoice(String gender) async {
    // Only change voice if it's different from current
    if (_currentVoiceGender == gender) {
      print('🎤 Voice already set to $gender, skipping');
      return;
    }
    
    print('🎤 Changing voice from $_currentVoiceGender to $gender');
    
    // Stop any ongoing speech first to prevent interruption
    await _tts.stop();
    
    if (gender == 'male') {
      await _tts.setVoice({"name": "Google UK English Male", "locale": "en-GB"});
    } else {
      await _tts.setVoice({"name": "Google UK English Female", "locale": "en-GB"});
    }
    
    _currentVoiceGender = gender;
    
    // CRITICAL: Re-setup completion handler immediately after voice change
    // setVoice() resets the handler, so we must re-register it
    _tts.setCompletionHandler(() {
      print('🔔 TTS Completion Handler called for segment $_currentSegmentIndex');
      if (mounted) {
        _onSegmentComplete();
      } else {
        print('⚠️ Widget not mounted, skipping');
      }
    });
    
    // CRITICAL: Add small delay to ensure voice change is fully applied on Android
    // Without this, speak() may be interrupted/cancelled immediately
    await Future.delayed(const Duration(milliseconds: 100));
    
    print('🎤 ✅ Voice changed and completion handler re-registered');
  }

  Future<void> _startPlayback() async {
    if (_currentSegmentIndex >= _meta.segments.length) {
      _handleComplete();
      return;
    }

    setState(() {
      _isPlaying = true;
      _isPaused = false;
    });

    await _playCurrentSegment();
  }

  Future<void> _playCurrentSegment() async {
    if (_currentSegmentIndex >= _meta.segments.length) return;

    print('🎵 _playCurrentSegment: index=$_currentSegmentIndex');
    
    final segment = _meta.segments[_currentSegmentIndex];
    
    print('🎵 Transcript: ${segment.transcript.substring(0, 50)}...');
    print('🎵 Voice: ${segment.voiceGender}');
    
    // Set voice and wait for it to complete (including handler re-registration)
    await _setVoice(segment.voiceGender);
    
    print('🎵 Voice set complete, about to speak...');
    
    // Speak
    final result = await _tts.speak(segment.transcript);
    
    print('🎵 TTS speak initiated, result: $result');
  }

  void _onSegmentComplete() {
    if (!mounted) return;
    
    print('🎯 _onSegmentComplete called. Current index: $_currentSegmentIndex');
    print('🎯 Current question state: $_currentQuestion');
    print('🎯 Segments with questions shown: $_segmentsWithQuestionsShown');
    
    final segment = _meta.segments[_currentSegmentIndex];

    // Check if we need to show a question for this segment
    // Only show question if:
    // 1. Current question is null (not already showing a question)
    // 2. Segment has questions
    // 3. Haven't shown this segment's questions yet
    if (_currentQuestion == null && 
        segment.questions != null && 
        segment.questions!.isNotEmpty &&
        !_segmentsWithQuestionsShown.contains(_currentSegmentIndex)) {
      print('📝 Segment has questions, showing question UI');
      
      // Mark this segment as having shown its question
      _segmentsWithQuestionsShown.add(_currentSegmentIndex);
      
      setState(() {
        _currentQuestion = segment.questions!.first;
        _isPlaying = false;
        _isPaused = true;
      });
    } else {
      print('▶️ No questions or already answered, moving to next segment');
      // Move to next segment
      setState(() {
        _currentSegmentIndex++;
        _isPlaying = true;
        _isPaused = false;
      });
      
      print('📍 New segment index: $_currentSegmentIndex, Total: ${_meta.segments.length}');
      
      if (_currentSegmentIndex < _meta.segments.length) {
        print('🎤 Playing segment $_currentSegmentIndex');
        _playCurrentSegment();
      } else {
        print('✅ All segments complete');
        _handleComplete();
      }
    }
  }

  void _handleQuestionAnswered(bool isCorrect, dynamic answer) {
    if (!mounted) return;
    
    // Show inline feedback instead of SnackBar
    setState(() {
      _feedbackMessage = isCorrect ? 'Correct! ✓' : 'Try again! ✗';
      _feedbackColor = isCorrect ? AppColors.primary : AppColors.cardinal;
    });

    if (isCorrect) {
      // Clear feedback after delay, then continue to next segment
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        
        print('✅ Question answered correctly, clearing question state');
        
        setState(() {
          _feedbackMessage = null;
          _feedbackColor = null;
          _currentQuestion = null;
          // Don't increment here - let _onSegmentComplete handle it
        });
        
        // Trigger segment completion to move to next
        _onSegmentComplete();
      });
    } else {
      // Clear feedback after delay but stay on same question
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        setState(() {
          _feedbackMessage = null;
          _feedbackColor = null;
        });
      });
    }
  }

  void _handleComplete() {
    setState(() {
      _isPlaying = false;
      _currentPosition = _totalDuration;
    });

    context.read<ExerciseBloc>().add(
          AnswerSelected(
            selectedAnswer: "completed",
            correctAnswer: "completed",
            exerciseId: _exerciseId,
          ),
        );
  }

  void _togglePlayPause() async {
    if (_currentQuestion != null) return; // Can't play while question active

    if (_isPlaying) {
      await _tts.stop();
      setState(() {
        _isPlaying = false;
        _isPaused = true;
      });
    } else {
      _startPlayback();
    }
  }

  void _seekBackward() async {
    await _tts.stop();
    // Go back 5 seconds or to previous segment
    final targetTime = _currentPosition - 5;
    
    // Find which segment this time belongs to
    int newIndex = 0;
    double accumulatedTime = 0;
    
    for (int i = 0; i < _meta.segments.length; i++) {
      final segmentDuration = _estimateSegmentDuration(i);
      if (accumulatedTime + segmentDuration > targetTime) {
        newIndex = i;
        break;
      }
      accumulatedTime += segmentDuration;
    }

    setState(() {
      _currentSegmentIndex = newIndex;
      _currentPosition = targetTime.clamp(0, _totalDuration);
    });

    if (!_isPaused) {
      _startPlayback();
    }
  }

  void _seekForward() async {
    await _tts.stop();
    // Go forward 5 seconds or to next segment
    final targetTime = _currentPosition + 5;
    
    int newIndex = _currentSegmentIndex;
    double accumulatedTime = _getSegmentStartTime(_currentSegmentIndex);
    
    for (int i = _currentSegmentIndex; i < _meta.segments.length; i++) {
      final segmentDuration = _estimateSegmentDuration(i);
      if (accumulatedTime + segmentDuration > targetTime) {
        newIndex = i;
        break;
      }
      accumulatedTime += segmentDuration;
    }

    setState(() {
      _currentSegmentIndex = newIndex.clamp(0, _meta.segments.length - 1);
      _currentPosition = targetTime.clamp(0, _totalDuration);
    });

    if (!_isPaused) {
      _startPlayback();
    }
  }

  @override
  void dispose() {
    _tts.stop();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseBloc, ExerciseState>(
      builder: (context, state) {
        if (state is! ExercisesLoaded) return const SizedBox.shrink();

        return Column(
          children: [
            // Media section (top)
            // _buildMediaSection(),

            // SizedBox(height: 16.h),

            // Question section (middle) - scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    _buildTitleSection(),
                    SizedBox(height: 20.h),
                    // Feedback message
                    if (_feedbackMessage != null)
                      Container(
                        margin: EdgeInsets.only(bottom: 16.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: _feedbackColor?.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: _feedbackColor ?? AppColors.primary,
                            width: 2.w,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _feedbackColor == AppColors.primary
                                  ? Icons.check_circle
                                  : Icons.error,
                              color: _feedbackColor,
                              size: 24.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              _feedbackMessage!,
                              style: AppTypography.defaultTextTheme()
                                  .titleMedium
                                  ?.copyWith(
                                    color: _feedbackColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    if (_currentQuestion != null)
                      _buildQuestionWidget()
                    else
                      _buildTranscriptSection(),
                  ],
                ),
              ),
            ),

            // Controls section (bottom)
            _buildControlsSection(),
          ],
        );
      },
    );
  }

  Widget _buildMediaSection() {
    if (_meta.media == null || _meta.media!.type == PodcastMediaType.none) {
      return _buildDefaultMediaPlaceholder();
    }

    // TODO: Implement GIF, Video, Lottie _buildDefaultMediaPlaceholderplayers
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
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isPlaying ? _pulseAnimation.value : 1.0,
              child: Icon(
                _isPlaying ? Icons.graphic_eq : Icons.podcasts,
                size: 80.sp,
                color: AppColors.macaw,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _meta.title,
          style: AppTypography.defaultTextTheme().headlineMedium?.copyWith(
                color: AppColors.eel,
                fontWeight: FontWeight.w700,
              ),
        ),
        if (_meta.description != null) ...[
          SizedBox(height: 8.h),
          Text(
            _meta.description!,
            style: AppTypography.defaultTextTheme().bodyMedium?.copyWith(
                  color: AppColors.wolf,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuestionWidget() {
    if (_currentQuestion == null) return const SizedBox.shrink();

    switch (_currentQuestion!.type) {
      case PodcastQuestionType.match:
        return PodcastMatchQuestionWidget(
          question: _currentQuestion as PodcastMatchQuestion,
          onAnswered: _handleQuestionAnswered,
        );
      case PodcastQuestionType.trueFalse:
        return PodcastTrueFalseQuestionWidget(
          question: _currentQuestion as PodcastTrueFalseQuestion,
          onAnswered: _handleQuestionAnswered,
        );
      case PodcastQuestionType.listenChoose:
        return PodcastListenChooseQuestionWidget(
          question: _currentQuestion as PodcastListenChooseQuestion,
          onAnswered: _handleQuestionAnswered,
        );
      case PodcastQuestionType.multipleChoice:
        return PodcastMultipleChoiceQuestionWidget(
          question: _currentQuestion as PodcastMultipleChoiceQuestion,
          onAnswered: _handleQuestionAnswered,
        );
    }
  }

  Widget _buildTranscriptSection() {
    if (!_meta.showTranscript) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _meta.segments.asMap().entries.map((entry) {
        final index = entry.key;
        final segment = entry.value;
        final isActive = index == _currentSegmentIndex;
        final isPast = index < _currentSegmentIndex;

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

  Widget _buildControlsSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.snow,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress bar
          Row(
            children: [
              Text(
                _formatDuration(_currentPosition),
                style: AppTypography.defaultTextTheme().labelSmall?.copyWith(
                      color: AppColors.wolf,
                    ),
              ),
              Expanded(
                child: Slider(
                  value: _currentPosition,
                  min: 0,
                  max: _totalDuration,
                  activeColor: AppColors.macaw,
                  inactiveColor: AppColors.swan,
                  onChanged: null, // Read-only for now
                ),
              ),
              Text(
                _formatDuration(_totalDuration),
                style: AppTypography.defaultTextTheme().labelSmall?.copyWith(
                      color: AppColors.wolf,
                    ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Seek backward 5s
              _buildControlButton(
                icon: Icons.replay_5,
                onPressed: _seekBackward,
                color: AppColors.wolf,
              ),

              SizedBox(width: 40.w),

              // Play/Pause
              _buildControlButton(
                icon: _isPlaying ? Icons.pause : Icons.play_arrow,
                onPressed: _togglePlayPause,
                color: AppColors.primary,
                size: 64.sp,
                isMain: true,
              ),

              SizedBox(width: 40.w),

              // Seek forward 5s
              _buildControlButton(
                icon: Icons.forward_5,
                onPressed: _seekForward,
                color: AppColors.wolf,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    double? size,
    bool isMain = false,
  }) {
    final iconSize = size ?? 32.sp;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: isMain ? 64.w : 48.w,
        height: isMain ? 64.h : 48.h,
        decoration: BoxDecoration(
          color: isMain ? color : color.withOpacity(0.1),
          shape: BoxShape.circle,
          boxShadow: isMain
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: isMain ? AppColors.snow : color,
        ),
      ),
    );
  }

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
*/
