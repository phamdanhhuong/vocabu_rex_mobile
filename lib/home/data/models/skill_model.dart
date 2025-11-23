import 'skill_level_model.dart';
import 'grammar_model.dart';

class SkillModel {
  final String id;
  final String title;
  final String? description;
  final int position;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<SkillLevelModel>? levels;
  final List<GrammarModel>? grammars;

  SkillModel({
    required this.id,
    required this.title,
    this.description,
    required this.position,
    this.createdAt,
    this.updatedAt,
    this.levels,
    this.grammars,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      position: json['position'] as int,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      levels: json['levels'] != null
          ? (json['levels'] as List)
                .map((level) => SkillLevelModel.fromJson(level))
                .toList()
          : null,
      grammars: json['grammars'] != null
          ? (json['grammars'] as List)
                .map((grammar) => GrammarModel.fromJson(grammar))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'position': position,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'levels': levels?.map((level) => level.toJson()).toList(),
      'grammars': grammars?.map((grammar) => grammar.toJson()).toList(),
    };
  }
}
