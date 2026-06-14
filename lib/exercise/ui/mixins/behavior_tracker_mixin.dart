import 'package:flutter/widgets.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_behavior_entity.dart';

/// A mixin that provides behavioral tracking capabilities to exercise widgets.
///
/// Any exercise widget State can mix this in to automatically track:
/// - Total time spent on the exercise
/// - Time to first user interaction (hesitation)
/// - Number of answer changes
/// - Chronological answer event log
///
/// Usage:
/// ```dart
/// class _MyExerciseState extends State<MyExercise> with BehaviorTrackerMixin {
///   @override
///   void initState() {
///     super.initState();
///     startBehaviorTracking(); // call after super.initState()
///   }
///
///   void _onUserSelect(String answer) {
///     recordAnswerEvent(answer, 'select');
///     // ... rest of selection logic
///   }
///
///   void _onSubmit() {
///     final data = buildBehaviorData(
///       exerciseId: widget.exerciseId,
///       exerciseType: 'multiple_choice',
///       isCorrect: isCorrect,
///       selectedAnswer: selected,
///       correctAnswer: correct,
///     );
///     // send data alongside answer
///   }
/// }
/// ```
mixin BehaviorTrackerMixin<T extends StatefulWidget> on State<T> {
  final Stopwatch _exerciseStopwatch = Stopwatch();
  final Stopwatch _firstActionStopwatch = Stopwatch();
  bool _hasFirstAction = false;
  int _answerChangeCount = 0;
  final List<AnswerEvent> _answerEvents = [];

  /// Call this in [initState] after super.initState().
  @protected
  void startBehaviorTracking() {
    _exerciseStopwatch
      ..reset()
      ..start();
    _firstActionStopwatch
      ..reset()
      ..start();
    _hasFirstAction = false;
    _answerChangeCount = 0;
    _answerEvents.clear();
  }

  /// Call this whenever the user interacts with an answer option.
  ///
  /// [answer] is the text of the option the user interacted with.
  /// [action] is a short label: "select", "deselect", "change", "type", "submit".
  @protected
  void recordAnswerEvent(String answer, String action) {
    if (!_hasFirstAction) {
      _firstActionStopwatch.stop();
      _hasFirstAction = true;
    }
    if (action == 'select' || action == 'change' || action == 'deselect') {
      _answerChangeCount++;
    }
    _answerEvents.add(AnswerEvent(
      answer: answer,
      timestampMs: _exerciseStopwatch.elapsedMilliseconds,
      action: action,
    ));
  }

  /// Stop the exercise timer. Call right before submitting.
  @protected
  void stopBehaviorTracking() {
    _exerciseStopwatch.stop();
    if (!_hasFirstAction) {
      _firstActionStopwatch.stop();
    }
  }

  /// Reset tracking state (e.g., when exercise is retried or next exercise loads).
  @protected
  void resetBehaviorTracking() {
    _exerciseStopwatch
      ..reset()
      ..start();
    _firstActionStopwatch
      ..reset()
      ..start();
    _hasFirstAction = false;
    _answerChangeCount = 0;
    _answerEvents.clear();
  }

  /// Build the final behavior data snapshot.
  ///
  /// Call this after [stopBehaviorTracking] and include the result in the
  /// bloc event sent to the backend.
  @protected
  ExerciseBehaviorData buildBehaviorData({
    required String exerciseId,
    required String exerciseType,
    required bool isCorrect,
    String? selectedAnswer,
    String? correctAnswer,
  }) {
    return ExerciseBehaviorData(
      exerciseId: exerciseId,
      exerciseType: exerciseType,
      timeSpentMs: _exerciseStopwatch.elapsedMilliseconds,
      timeToFirstActionMs: _firstActionStopwatch.elapsedMilliseconds,
      answerChangeCount: _answerChangeCount,
      answerEvents: List.unmodifiable(_answerEvents),
      isCorrect: isCorrect,
      selectedAnswer: selectedAnswer,
      correctAnswer: correctAnswer,
    );
  }

  // ── Getters for subclass convenience ──

  int get elapsedMs => _exerciseStopwatch.elapsedMilliseconds;
  int get firstActionMs => _firstActionStopwatch.elapsedMilliseconds;
  int get answerChangeCount => _answerChangeCount;
  bool get hasFirstAction => _hasFirstAction;
}
