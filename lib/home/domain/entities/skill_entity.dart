import 'package:vocabu_rex_mobile/home/data/models/skill_model.dart';
import 'skill_level_entity.dart';
import 'grammar_entity.dart';

class SkillEntity {
  final String id;
  final String title;
  final String? description;
  final int position;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<SkillLevelEntity>? levels;
  final List<GrammarEntity>? grammars;

  SkillEntity({
    required this.id,
    required this.title,
    this.description,
    required this.position,
    this.createdAt,
    this.updatedAt,
    this.levels,
    this.grammars,
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
      grammars: model.grammars
          ?.map((grammar) => GrammarEntity.fromModel(grammar))
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
    List<GrammarEntity>? grammars,
  }) {
    return SkillEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      levels: levels ?? this.levels,
      grammars: grammars ?? this.grammars,
    );
  }
}
