import 'lesson_model.dart';

class SkillLevelModel {
  final String skillId;
  final int level;
  final String description;
  final List<LessonModel>? lessons;

  SkillLevelModel({
    required this.skillId,
    required this.level,
    required this.description,
    this.lessons,
  });

  factory SkillLevelModel.fromJson(Map<String, dynamic> json) {
    return SkillLevelModel(
      skillId: json['skillId'] as String,
      level: json['level'] as int,
      description: json['description'] as String,
      lessons: json['lessons'] != null
          ? (json['lessons'] as List)
                .map((lesson) => LessonModel.fromJson(lesson))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skillId': skillId,
      'level': level,
      'description': description,
      'lessons': lessons?.map((lesson) => lesson.toJson()).toList(),
    };
  }
}
