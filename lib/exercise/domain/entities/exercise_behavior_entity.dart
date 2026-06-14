/// Represents a single answer interaction event during an exercise.
///
/// Each time the user selects, deselects, changes, or submits an answer,
/// an [AnswerEvent] is recorded with the relative timestamp.
class AnswerEvent {
  /// The answer text the user interacted with.
  final String answer;

  /// Milliseconds since the exercise was first displayed.
  final int timestampMs;

  /// The type of action: "select", "deselect", "change", "submit", "type".
  final String action;

  const AnswerEvent({
    required this.answer,
    required this.timestampMs,
    required this.action,
  });

  Map<String, dynamic> toJson() => {
    'answer': answer,
    'timestampMs': timestampMs,
    'action': action,
  };

  factory AnswerEvent.fromJson(Map<String, dynamic> json) => AnswerEvent(
    answer: json['answer'] as String,
    timestampMs: json['timestampMs'] as int,
    action: json['action'] as String,
  );
}

/// Captures detailed behavioral data for a single exercise attempt.
///
/// This data is collected on the client side as the user interacts
/// with an exercise and is sent alongside the answer result when the
/// lesson is submitted.
class ExerciseBehaviorData {
  /// The exercise this behavior data belongs to.
  final String exerciseId;

  /// Exercise type (e.g. "multiple_choice", "fill_blank", "translate").
  final String exerciseType;

  /// Total time the user spent on this exercise, in milliseconds.
  final int timeSpentMs;

  /// Time from when the exercise was displayed to the user's first
  /// interaction (tap / keystroke), in milliseconds.
  /// A high value may indicate the user was reading / thinking.
  final int timeToFirstActionMs;

  /// Number of times the user changed their selected answer before submitting.
  final int answerChangeCount;

  /// Chronological log of every answer interaction.
  final List<AnswerEvent> answerEvents;

  /// Whether the final answer was correct.
  final bool isCorrect;

  /// The answer the user submitted.
  final String? selectedAnswer;

  /// The correct answer for reference.
  final String? correctAnswer;

  const ExerciseBehaviorData({
    required this.exerciseId,
    required this.exerciseType,
    required this.timeSpentMs,
    required this.timeToFirstActionMs,
    required this.answerChangeCount,
    required this.answerEvents,
    required this.isCorrect,
    this.selectedAnswer,
    this.correctAnswer,
  });

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'exerciseType': exerciseType,
    'timeSpentMs': timeSpentMs,
    'timeToFirstActionMs': timeToFirstActionMs,
    'answerChangeCount': answerChangeCount,
    'answerEvents': answerEvents.map((e) => e.toJson()).toList(),
    'isCorrect': isCorrect,
    if (selectedAnswer != null) 'selectedAnswer': selectedAnswer,
    if (correctAnswer != null) 'correctAnswer': correctAnswer,
  };

  factory ExerciseBehaviorData.fromJson(Map<String, dynamic> json) =>
      ExerciseBehaviorData(
        exerciseId: json['exerciseId'] as String,
        exerciseType: json['exerciseType'] as String,
        timeSpentMs: json['timeSpentMs'] as int,
        timeToFirstActionMs: json['timeToFirstActionMs'] as int,
        answerChangeCount: json['answerChangeCount'] as int,
        answerEvents: (json['answerEvents'] as List)
            .map((e) => AnswerEvent.fromJson(e as Map<String, dynamic>))
            .toList(),
        isCorrect: json['isCorrect'] as bool,
        selectedAnswer: json['selectedAnswer'] as String?,
        correctAnswer: json['correctAnswer'] as String?,
      );
}
