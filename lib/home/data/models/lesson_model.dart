import '../../../exercise/data/models/exercise_model.dart';

class LessonModel {
  final String id;
  final String skillId;
  final int skillLevel;
  final String title;
  final int position;
  final DateTime createdAt;
  final List<ExerciseModel>? exercises;
  final int? exerciseCount;

  LessonModel({
    required this.id,
    required this.skillId,
    required this.skillLevel,
    required this.title,
    required this.position,
    required this.createdAt,
    this.exercises,
    this.exerciseCount,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String,
      skillId: json['skillId'] as String,
      skillLevel: json['skillLevel'] as int,
      title: json['title'] as String,
      position: json['position'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      exercises: json['exercises'] != null
          ? (json['exercises'] as List)
                .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      exerciseCount: json['exerciseCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'skillId': skillId,
      'skillLevel': skillLevel,
      'title': title,
      'position': position,
      'createdAt': createdAt.toIso8601String(),
      'exercises': exercises?.map((e) => e.toJson()).toList(),
      'exerciseCount': exerciseCount,
    };
  }
}
