class ExerciseResultEntity {
  final String lessonId;
  final String skillId;
  final List<ExerciseAnswerEntity> exercises;

  ExerciseResultEntity({
    required this.lessonId,
    required this.skillId,
    required this.exercises,
  });

  factory ExerciseResultEntity.fromJson(Map<String, dynamic> json) {
    return ExerciseResultEntity(
      lessonId: json['lessonId'] as String,
      skillId: json['skillId'] as String,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => ExerciseAnswerEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'skillId': skillId,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }

  ExerciseResultEntity copyWith({
    String? lessonId,
    String? skillId,
    List<ExerciseAnswerEntity>? exercises,
  }) {
    return ExerciseResultEntity(
      lessonId: lessonId ?? this.lessonId,
      skillId: skillId ?? this.skillId,
      exercises: exercises ?? this.exercises,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExerciseResultEntity &&
        other.lessonId == lessonId &&
        other.skillId == skillId &&
        _listEquals(other.exercises, exercises);
  }

  @override
  int get hashCode => lessonId.hashCode ^ skillId.hashCode ^ exercises.hashCode;

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
    return 'ExerciseResultEntity(lessonId: $lessonId, skillId: $skillId, exercises: $exercises)';
  }
}

class ExerciseAnswerEntity {
  final String exerciseId;
  final bool isCorrect;

  ExerciseAnswerEntity({required this.exerciseId, required this.isCorrect});

  factory ExerciseAnswerEntity.fromJson(Map<String, dynamic> json) {
    return ExerciseAnswerEntity(
      exerciseId: json['exerciseId'] as String,
      isCorrect: json['isCorrect'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {'exerciseId': exerciseId, 'isCorrect': isCorrect};
  }

  ExerciseAnswerEntity copyWith({String? exerciseId, bool? isCorrect}) {
    return ExerciseAnswerEntity(
      exerciseId: exerciseId ?? this.exerciseId,
      isCorrect: isCorrect ?? this.isCorrect,
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
    return 'ExerciseAnswerEntity(exerciseId: $exerciseId, isCorrect: $isCorrect)';
  }
}
