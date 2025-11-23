import 'package:vocabu_rex_mobile/home/data/models/skill_part_model.dart';
import 'skill_entity.dart';

class SkillPartEntity {
  final String id;
  final String name;
  final String? description;
  final int position;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int totalSkills;
  final int completedSkills;
  final int progressPercentage;
  final List<SkillEntity>? skills;

  SkillPartEntity({
    required this.id,
    required this.name,
    this.description,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
    required this.totalSkills,
    required this.completedSkills,
    required this.progressPercentage,
    this.skills,
  });

  factory SkillPartEntity.fromModel(SkillPartModel model) {
    return SkillPartEntity(
      id: model.id,
      name: model.name,
      description: model.description,
      position: model.position,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      totalSkills: model.totalSkills,
      completedSkills: model.completedSkills,
      progressPercentage: model.progressPercentage,
      skills: model.skills
          ?.map((skill) => SkillEntity.fromModel(skill))
          .toList(),
    );
  }

  SkillPartEntity copyWith({
    String? id,
    String? name,
    String? description,
    int? position,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? totalSkills,
    int? completedSkills,
    int? progressPercentage,
    List<SkillEntity>? skills,
  }) {
    return SkillPartEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalSkills: totalSkills ?? this.totalSkills,
      completedSkills: completedSkills ?? this.completedSkills,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      skills: skills ?? this.skills,
    );
  }
}
