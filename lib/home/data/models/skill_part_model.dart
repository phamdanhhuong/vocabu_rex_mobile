import 'skill_model.dart';

class SkillPartModel {
  final String id;
  final String name;
  final String? description;
  final int position;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int totalSkills;
  final int completedSkills;
  final int progressPercentage;
  final List<SkillModel>? skills;

  SkillPartModel({
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

  factory SkillPartModel.fromJson(Map<String, dynamic> json) {
    final skillsList = json['skills'] != null
        ? (json['skills'] as List)
            .map((skill) => SkillModel.fromJson(skill))
            .toList()
        : <SkillModel>[];
    
    return SkillPartModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      position: json['position'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      totalSkills: (json['totalSkills'] as int?) ?? skillsList.length,
      completedSkills: (json['completedSkills'] as int?) ?? 0,
      progressPercentage: (json['progressPercentage'] as int?) ?? 0,
      skills: skillsList.isEmpty ? null : skillsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'position': position,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'totalSkills': totalSkills,
      'completedSkills': completedSkills,
      'progressPercentage': progressPercentage,
      'skills': skills?.map((skill) => skill.toJson()).toList(),
    };
  }
}
