import 'package:vocabu_rex_mobile/home/data/models/lesson_model.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_entity.dart';

class LessonEntity {
  final String id;
  final String skillId;
  final int skillLevel;
  final String title;
  final int position;
  final DateTime createdAt;
  final List<ExerciseEntity>? exercises;
  final int? exerciseCount;

  LessonEntity({
    required this.id,
    required this.skillId,
    required this.skillLevel,
    required this.title,
    required this.position,
    required this.createdAt,
    this.exercises,
    this.exerciseCount,
  });

  factory LessonEntity.fromModel(LessonModel model) {
    return LessonEntity(
      id: model.id,
      skillId: model.skillId,
      skillLevel: model.skillLevel,
      title: model.title,
      position: model.position,
      createdAt: model.createdAt,
      exercises: model.exercises
          ?.map((e) => ExerciseEntity.fromModel(e))
          .toList(),
      exerciseCount: model.exerciseCount,
    );
  }

  // Business logic methods
  bool get hasExercises => exercises != null && exercises!.isNotEmpty;

  int get totalExercises => exerciseCount ?? exercises?.length ?? 0;

  bool get isCompleted =>
      exercises?.every((e) => e.isContentBased || e.isInteractive) ?? false;

  LessonEntity copyWith({
    String? id,
    String? skillId,
    int? skillLevel,
    String? title,
    int? position,
    DateTime? createdAt,
    List<ExerciseEntity>? exercises,
    int? exerciseCount,
  }) {
    return LessonEntity(
      id: id ?? this.id,
      skillId: skillId ?? this.skillId,
      skillLevel: skillLevel ?? this.skillLevel,
      title: title ?? this.title,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      exercises: exercises ?? this.exercises,
      exerciseCount: exerciseCount ?? this.exerciseCount,
    );
  }
}
