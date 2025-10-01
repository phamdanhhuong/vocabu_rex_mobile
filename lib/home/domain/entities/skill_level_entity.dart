import 'package:vocabu_rex_mobile/home/data/models/skill_level_model.dart';
import 'lesson_entity.dart';

class SkillLevelEntity {
  final String skillId;
  final int level;
  final String description;
  final List<LessonEntity>? lessons;

  SkillLevelEntity({
    required this.skillId,
    required this.level,
    required this.description,
    this.lessons,
  });

  factory SkillLevelEntity.fromModel(SkillLevelModel model) {
    return SkillLevelEntity(
      skillId: model.skillId,
      level: model.level,
      description: model.description,
      lessons: model.lessons
          ?.map((lesson) => LessonEntity.fromModel(lesson))
          .toList(),
    );
  }

  SkillLevelEntity copyWith({
    String? skillId,
    int? level,
    String? description,
    List<LessonEntity>? lessons,
  }) {
    return SkillLevelEntity(
      skillId: skillId ?? this.skillId,
      level: level ?? this.level,
      description: description ?? this.description,
      lessons: lessons ?? this.lessons,
    );
  }
}
