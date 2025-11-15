import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/podcast_question_entity.dart';

/// State class for Enhanced Podcast player
class PodcastState {
  final bool isPlaying;
  final bool isPaused;
  final int currentSegmentIndex;
  final PodcastQuestionEntity? currentQuestion;
  final String? currentVoiceGender;
  final Set<int> segmentsWithQuestionsShown;
  final String? feedbackMessage;
  final Color? feedbackColor;

  const PodcastState({
    this.isPlaying = false,
    this.isPaused = false,
    this.currentSegmentIndex = 0,
    this.currentQuestion,
    this.currentVoiceGender,
    this.segmentsWithQuestionsShown = const {},
    this.feedbackMessage,
    this.feedbackColor,
  });

  PodcastState copyWith({
    bool? isPlaying,
    bool? isPaused,
    int? currentSegmentIndex,
    PodcastQuestionEntity? currentQuestion,
    bool clearQuestion = false,
    String? currentVoiceGender,
    Set<int>? segmentsWithQuestionsShown,
    String? feedbackMessage,
    bool clearFeedback = false,
    Color? feedbackColor,
  }) {
    return PodcastState(
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      currentSegmentIndex: currentSegmentIndex ?? this.currentSegmentIndex,
      currentQuestion: clearQuestion ? null : (currentQuestion ?? this.currentQuestion),
      currentVoiceGender: currentVoiceGender ?? this.currentVoiceGender,
      segmentsWithQuestionsShown: segmentsWithQuestionsShown ?? this.segmentsWithQuestionsShown,
      feedbackMessage: clearFeedback ? null : (feedbackMessage ?? this.feedbackMessage),
      feedbackColor: clearFeedback ? null : (feedbackColor ?? this.feedbackColor),
    );
  }
}
