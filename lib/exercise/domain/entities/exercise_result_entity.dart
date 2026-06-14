import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_behavior_entity.dart';

class ExerciseResultEntity {
  final String lessonId;
  final String skillId;
  final List<ExerciseAnswerEntity> exercises;
  final int? timeSpent;
  final List<ExerciseBehaviorData> behaviorData;

  ExerciseResultEntity({
    required this.lessonId,
    required this.skillId,
    required this.exercises,
    this.timeSpent,
    this.behaviorData = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'skillId': skillId,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      if (timeSpent != null) 'timeSpent': timeSpent,
      if (behaviorData.isNotEmpty)
        'behaviorData': behaviorData.map((b) => b.toJson()).toList(),
    };
  }

  ExerciseResultEntity copyWith({
    String? lessonId,
    String? skillId,
    List<ExerciseAnswerEntity>? exercises,
    int? timeSpent,
    List<ExerciseBehaviorData>? behaviorData,
  }) {
    return ExerciseResultEntity(
      lessonId: lessonId ?? this.lessonId,
      skillId: skillId ?? this.skillId,
      exercises: exercises ?? this.exercises,
      timeSpent: timeSpent ?? this.timeSpent,
      behaviorData: behaviorData ?? this.behaviorData,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExerciseResultEntity &&
        other.lessonId == lessonId &&
        other.skillId == skillId &&
        other.timeSpent == timeSpent &&
        _listEquals(other.exercises, exercises);
  }

  @override
  int get hashCode => lessonId.hashCode ^ skillId.hashCode ^ timeSpent.hashCode ^ exercises.hashCode;

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'ExerciseResultEntity(lessonId: $lessonId, skillId: $skillId, timeSpent: $timeSpent, exercises: $exercises, behaviorData: ${behaviorData.length} items)';
  }
}

class ExerciseAnswerEntity {
  final String exerciseId;
  final bool isCorrect;
  final int incorrectCount;
  /// Behavioral tracking fields — populated by exercise widgets.
  final int? timeSpentMs;
  final int? timeToFirstActionMs;
  final int? answerChangeCount;

  ExerciseAnswerEntity({
    required this.exerciseId,
    required this.isCorrect,
    required this.incorrectCount,
    this.timeSpentMs,
    this.timeToFirstActionMs,
    this.answerChangeCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'isCorrect': isCorrect,
      'incorrectCount': incorrectCount,
      if (timeSpentMs != null) 'timeSpentMs': timeSpentMs,
      if (timeToFirstActionMs != null) 'timeToFirstActionMs': timeToFirstActionMs,
      if (answerChangeCount != null) 'answerChangeCount': answerChangeCount,
    };
  }

  ExerciseAnswerEntity copyWith({
    String? exerciseId,
    bool? isCorrect,
    int? incorrectCount,
    int? timeSpentMs,
    int? timeToFirstActionMs,
    int? answerChangeCount,
  }) {
    return ExerciseAnswerEntity(
      exerciseId: exerciseId ?? this.exerciseId,
      isCorrect: isCorrect ?? this.isCorrect,
      incorrectCount: incorrectCount ?? this.incorrectCount,
      timeSpentMs: timeSpentMs ?? this.timeSpentMs,
      timeToFirstActionMs: timeToFirstActionMs ?? this.timeToFirstActionMs,
      answerChangeCount: answerChangeCount ?? this.answerChangeCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExerciseAnswerEntity &&
        other.exerciseId == exerciseId &&
        other.isCorrect == isCorrect;
  }

  @override
  int get hashCode => exerciseId.hashCode ^ isCorrect.hashCode;

  @override
  String toString() {
    return 'ExerciseAnswerEntity(exerciseId: $exerciseId, isCorrect: $isCorrect, incorrectCount: $incorrectCount, timeSpentMs: $timeSpentMs, answerChangeCount: $answerChangeCount)';
  }
}
