import 'package:vocabu_rex_mobile/home/data/models/skill_model.dart';
import 'skill_level_entity.dart';

class SkillEntity {
  final String id;
  final String title;
  final String? description;
  final int position;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<SkillLevelEntity>? levels;

  SkillEntity({
    required this.id,
    required this.title,
    this.description,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
    this.levels,
  });

  factory SkillEntity.fromModel(SkillModel model) {
    return SkillEntity(
      id: model.id,
      title: model.title,
      description: model.description,
      position: model.position,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      levels: model.levels
          ?.map((level) => SkillLevelEntity.fromModel(level))
          .toList(),
    );
  }

  SkillEntity copyWith({
    String? id,
    String? title,
    String? description,
    int? position,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<SkillLevelEntity>? levels,
  }) {
    return SkillEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      levels: levels ?? this.levels,
    );
  }
}
