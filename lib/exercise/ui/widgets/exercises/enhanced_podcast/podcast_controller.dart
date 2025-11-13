import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/enhanced_podcast_meta_entity.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'podcast_state.dart';

/// Controller for Enhanced Podcast player
/// Handles TTS, playback logic, and state management
class PodcastController extends ChangeNotifier {
  final EnhancedPodcastMetaEntity meta;
  final FlutterTts tts;
  final VoidCallback onComplete;

  PodcastState _state = const PodcastState();
  PodcastState get state => _state;
  
  // Flag to check if disposed
  bool _isDisposed = false;
  
  // OPTIMIZATION: Cache available voices to avoid repeated platform channel calls
  List<dynamic>? _cachedVoices;

  PodcastController({
    required this.meta,
    required this.tts,
    required this.onComplete,
  }) {
    _initialize();
  }

  void _initialize() {
    _setupTts();
    startPlayback();
  }

  Future<void> _setupTts() async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.8);
    await tts.setVolume(1.0);
    
    // OPTIMIZATION: Load and cache voices once during initialization
    try {
      _cachedVoices = await tts.getVoices;
      print('🎤 Cached ${_cachedVoices?.length ?? 0} voices during initialization');
    } catch (e) {
      print('⚠️ Error caching voices: $e');
      _cachedVoices = null;
    }
    
    // BACK TO OLD LOGIC: Use awaitSpeakCompletion for reliability
    await tts.awaitSpeakCompletion(true);
  }

  Future<void> _setVoice(String gender) async {
    // Only change voice if it's different from current
    if (_state.currentVoiceGender == gender) {
      print('🎤 Voice already set to $gender, skipping');
      return;
    }

    print('🎤 Changing voice from ${_state.currentVoiceGender} to $gender');

    // Stop any ongoing speech first to prevent interruption
    await tts.stop();

    // Use dynamic voice selection based on available voices
    await _setVoiceDynamic(gender);
    
    _updateState(_state.copyWith(currentVoiceGender: gender));

    print('🎤 ✅ Voice changed');
  }

  /// FIXED: Dynamic voice selection based on available voices
  Future<void> _setVoiceDynamic(String gender) async {
    try {
      // OPTIMIZATION: Use cached voices instead of calling getVoices every time
      final voices = _cachedVoices;
      
      if (voices == null || voices.isEmpty) {
        print('⚠️ No voices available, using default');
        return;
      }

      // Find voice matching locale and gender
      const targetLocale = 'en-gb';
      final targetGender = gender.toLowerCase();
      
      // Try to find exact match
      dynamic selectedVoice = voices.firstWhere(
        (voice) {
          final name = voice['name']?.toString().toLowerCase() ?? '';
          final locale = voice['locale']?.toString().toLowerCase() ?? '';
          
          return locale.contains(targetLocale) && 
                 (name.contains(targetGender) || name.contains('male'));
        },
        orElse: () => null,
      );

      // Fallback: Any en-GB voice
      if (selectedVoice == null) {
        selectedVoice = voices.firstWhere(
          (voice) => voice['locale']?.toString().toLowerCase().contains(targetLocale) ?? false,
          orElse: () => null,
        );
      }

      // Fallback: Any English voice
      if (selectedVoice == null) {
        selectedVoice = voices.firstWhere(
          (voice) => voice['locale']?.toString().startsWith('en') ?? false,
          orElse: () => null,
        );
      }

      if (selectedVoice != null) {
        print('🎤 Selected voice: ${selectedVoice['name']} (${selectedVoice['locale']})');
        
        // FIXED: Cast to proper Map<String, String> format
        final voiceMap = {
          'name': selectedVoice['name']?.toString() ?? '',
          'locale': selectedVoice['locale']?.toString() ?? '',
        };
        
        await tts.setVoice(voiceMap);
      } else {
        print('⚠️ No suitable voice found, using system default');
      }
    } catch (e) {
      print('⚠️ Error setting voice: $e, using default');
    }
  }

  Future<void> startPlayback() async {
    if (_state.currentSegmentIndex >= meta.segments.length) {
      _handleComplete();
      return;
    }

    _updateState(_state.copyWith(
      isPlaying: true,
      isPaused: false,
    ));

    // OLD LOGIC: Sequential playback with while loop
    await _playSegmentsSequentially();
  }

  Future<void> _playSegmentsSequentially() async {
    while (_state.currentSegmentIndex < meta.segments.length) {
      if (!_state.isPlaying || _isDisposed) break;

      final segment = meta.segments[_state.currentSegmentIndex];
      
      print('🎵 Playing segment ${_state.currentSegmentIndex}: ${segment.transcript.substring(0, segment.transcript.length > 50 ? 50 : segment.transcript.length)}...');

      // Set voice for this segment
      await _setVoice(segment.voiceGender);
      
      // Stop before speaking (prevent overlap)
      await tts.stop();

      // Speak and WAIT for completion (awaitSpeakCompletion is enabled)
      await tts.speak(segment.transcript);
      
      print('🎵 Segment ${_state.currentSegmentIndex} completed');

      // Check if this segment has questions
      if (segment.questions != null &&
          segment.questions!.isNotEmpty &&
          !_state.segmentsWithQuestionsShown.contains(_state.currentSegmentIndex)) {
        
        print('📝 Segment has questions, pausing playback');
        
        // Mark this segment as having shown its question
        final updatedShown = Set<int>.from(_state.segmentsWithQuestionsShown)
          ..add(_state.currentSegmentIndex);

        _updateState(_state.copyWith(
          currentQuestion: segment.questions!.first,
          isPlaying: false,
          isPaused: true,
          segmentsWithQuestionsShown: updatedShown,
        ));
        
        // Exit loop - will resume when question is answered
        return;
      }

      // Move to next segment
      final newIndex = _state.currentSegmentIndex + 1;
      _updateState(_state.copyWith(currentSegmentIndex: newIndex));
      
      if (newIndex >= meta.segments.length) {
        print('✅ All segments complete');
        _handleComplete();
        return;
      }
    }
    
    _updateState(_state.copyWith(isPlaying: false));
  }

  Future<void> _playCurrentSegment() async {
    if (_state.currentSegmentIndex >= meta.segments.length) return;

    print('🎵 _playCurrentSegment: index=${_state.currentSegmentIndex}');

    final segment = meta.segments[_state.currentSegmentIndex];

    print('� Transcript: ${segment.transcript.substring(0, segment.transcript.length > 50 ? 50 : segment.transcript.length)}...');
    print('🎵 Voice: ${segment.voiceGender}');

    // Set voice and wait for it to complete
    await _setVoice(segment.voiceGender);

    print('🎵 Voice set complete, about to speak...');

    // Speak
    await tts.speak(segment.transcript);

    print('🎵 TTS speak completed');
  }

  void handleQuestionAnswered(bool isCorrect, dynamic answer) {
    // Show inline feedback
    _updateState(_state.copyWith(
      feedbackMessage: isCorrect ? 'Correct! ✓' : 'Try again! ✗',
      feedbackColor: isCorrect ? AppColors.primary : AppColors.cardinal,
    ));

    if (isCorrect) {
      // Clear feedback after delay, then continue to next segment
      Future.delayed(const Duration(milliseconds: 800), () {
        print('✅ Question answered correctly, clearing question state');

        _updateState(_state.copyWith(
          clearFeedback: true,
          clearQuestion: true,
        ));

        // Move to next segment and continue playback
        final newIndex = _state.currentSegmentIndex + 1;
        _updateState(_state.copyWith(
          currentSegmentIndex: newIndex,
          isPlaying: true,
          isPaused: false,
        ));
        
        // Resume sequential playback
        _playSegmentsSequentially();
      });
    } else {
      // Clear feedback after delay but stay on same question
      Future.delayed(const Duration(milliseconds: 1500), () {
        _updateState(_state.copyWith(clearFeedback: true));
      });
    }
  }

  void _handleComplete() {
    _updateState(_state.copyWith(
      isPlaying: false,
    ));

    onComplete();
  }

  Future<void> togglePlayPause() async {
    if (_state.currentQuestion != null) return; // Can't play while question active

    if (_state.isPlaying) {
      await tts.stop();
      _updateState(_state.copyWith(
        isPlaying: false,
        isPaused: true,
      ));
    } else {
      startPlayback();
    }
  }

  /// Tua lùi segment hiện tại (replay từ đầu)
  Future<void> seekBackward() async {
    await tts.stop();
    
    // Replay current segment from beginning
    print('⏪ Replaying segment ${_state.currentSegmentIndex} from start');
    
    if (!_state.isPaused) {
      await _playCurrentSegment();
    }
  }

  /// Tua tới segment tiếp theo
  Future<void> seekForward() async {
    await tts.stop();
    
    final nextIndex = _state.currentSegmentIndex + 1;
    
    if (nextIndex >= meta.segments.length) {
      print('⏩ Already at last segment');
      return;
    }
    
    print('⏩ Skipping to segment $nextIndex');
    
    // Check if current segment has unanswered question
    final currentSegment = meta.segments[_state.currentSegmentIndex];
    if (currentSegment.questions != null && 
        currentSegment.questions!.isNotEmpty &&
        !_state.segmentsWithQuestionsShown.contains(_state.currentSegmentIndex)) {
      print('⚠️ Warning: Skipping segment with unanswered question');
      // Mark as shown to prevent re-showing
      final updatedShown = Set<int>.from(_state.segmentsWithQuestionsShown)
        ..add(_state.currentSegmentIndex);
      _updateState(_state.copyWith(segmentsWithQuestionsShown: updatedShown));
    }
    
    _updateState(_state.copyWith(
      currentSegmentIndex: nextIndex,
    ));

    if (!_state.isPaused) {
      await _playCurrentSegment();
    }
  }

  void _updateState(PodcastState newState) {
    if (_isDisposed) {
      print('⚠️ Attempted to update state after dispose, ignoring');
      return;
    }
    _state = newState;
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    print('🗑️ Disposing PodcastController...');
    
    // Set disposed flag first
    _isDisposed = true;
    
    // Stop TTS
    await tts.stop();
    
    super.dispose();
    
    print('🗑️ PodcastController disposed');
  }
}
