import 'exercise_type.dart';

class ExerciseModel {
  final String id;
  final String lessonId;
  final ExerciseType exerciseType;
  final String? prompt;
  final Map<String, dynamic>? meta;
  final int position;
  final DateTime createdAt;
  final bool isInteractive;
  final bool isContentBased;

  ExerciseModel({
    required this.id,
    required this.lessonId,
    required this.exerciseType,
    this.prompt,
    this.meta,
    required this.position,
    required this.createdAt,
    required this.isInteractive,
    required this.isContentBased,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      exerciseType: ExerciseType.fromString(json['exerciseType'] as String),
      prompt: json['prompt'] as String?,
      meta: json['meta'] as Map<String, dynamic>?,
      position: json['position'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isInteractive: json['isInteractive'] as bool,
      isContentBased: json['isContentBased'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lessonId': lessonId,
      'exerciseType': exerciseType.value,
      'prompt': prompt,
      'meta': meta,
      'position': position,
      'createdAt': createdAt.toIso8601String(),
      'isInteractive': isInteractive,
      'isContentBased': isContentBased,
    };
  }
}
