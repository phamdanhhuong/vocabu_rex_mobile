import 'package:vocabu_rex_mobile/home/data/models/lesson_model.dart';

class LessonEntity {
  final String id;
  final String skillId;
  final int skillLevel;
  final String title;
  final int position;
  final DateTime createdAt;

  LessonEntity({
    required this.id,
    required this.skillId,
    required this.skillLevel,
    required this.title,
    required this.position,
    required this.createdAt,
  });

  factory LessonEntity.fromModel(LessonModel model) {
    return LessonEntity(
      id: model.id,
      skillId: model.skillId,
      skillLevel: model.skillLevel,
      title: model.title,
      position: model.position,
      createdAt: model.createdAt,
    );
  }

  LessonEntity copyWith({
    String? id,
    String? skillId,
    int? skillLevel,
    String? title,
    int? position,
    DateTime? createdAt,
  }) {
    return LessonEntity(
      id: id ?? this.id,
      skillId: skillId ?? this.skillId,
      skillLevel: skillLevel ?? this.skillLevel,
      title: title ?? this.title,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
