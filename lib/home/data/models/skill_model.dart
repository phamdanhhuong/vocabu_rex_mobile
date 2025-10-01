import 'skill_level_model.dart';

class SkillModel {
  final String id;
  final String title;
  final String? description;
  final int position;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<SkillLevelModel>? levels;

  SkillModel({
    required this.id,
    required this.title,
    this.description,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
    this.levels,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      position: json['position'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      levels: json['levels'] != null
          ? (json['levels'] as List)
                .map((level) => SkillLevelModel.fromJson(level))
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'levels': levels?.map((level) => level.toJson()).toList(),
    };
  }
}
