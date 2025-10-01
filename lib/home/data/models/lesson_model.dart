class LessonModel {
  final String id;
  final String skillId;
  final int skillLevel;
  final String title;
  final int position;
  final DateTime createdAt;

  LessonModel({
    required this.id,
    required this.skillId,
    required this.skillLevel,
    required this.title,
    required this.position,
    required this.createdAt,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String,
      skillId: json['skillId'] as String,
      skillLevel: json['skillLevel'] as int,
      title: json['title'] as String,
      position: json['position'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'skillId': skillId,
      'skillLevel': skillLevel,
      'title': title,
      'position': position,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
