class ExerciseResultEntity {
  final String lessonId;
  final String skillId;
  final List<ExerciseAnswerEntity> exercises;
  final int? timeSpent;

  ExerciseResultEntity({
    required this.lessonId,
    required this.skillId,
    required this.exercises,
    this.timeSpent,
  });

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'skillId': skillId,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      if (timeSpent != null) 'timeSpent': timeSpent,
    };
  }

  ExerciseResultEntity copyWith({
    String? lessonId,
    String? skillId,
    List<ExerciseAnswerEntity>? exercises,
    int? timeSpent,
  }) {
    return ExerciseResultEntity(
      lessonId: lessonId ?? this.lessonId,
      skillId: skillId ?? this.skillId,
      exercises: exercises ?? this.exercises,
      timeSpent: timeSpent ?? this.timeSpent,
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
    return 'ExerciseResultEntity(lessonId: $lessonId, skillId: $skillId, timeSpent: $timeSpent, exercises: $exercises)';
  }
}

class ExerciseAnswerEntity {
  final String exerciseId;
  final bool isCorrect;
  final int incorrectCount;

  ExerciseAnswerEntity({
    required this.exerciseId,
    required this.isCorrect,
    required this.incorrectCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'isCorrect': isCorrect,
      'incorrectCount': incorrectCount,
    };
  }

  ExerciseAnswerEntity copyWith({
    String? exerciseId,
    bool? isCorrect,
    int? incorrectCount,
  }) {
    return ExerciseAnswerEntity(
      exerciseId: exerciseId ?? this.exerciseId,
      isCorrect: isCorrect ?? this.isCorrect,
      incorrectCount: incorrectCount ?? this.incorrectCount,
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
    return 'ExerciseAnswerEntity(exerciseId: $exerciseId, isCorrect: $isCorrect, incorrectCount: $incorrectCount)';
  }
}
