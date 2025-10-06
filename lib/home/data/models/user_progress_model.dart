class UserProgressModel {
  final String userId;
  final String skillId;
  final int levelReached;
  final int lessonPosition;
  final DateTime lastPracticed;
  final int completionPercentage;

  UserProgressModel({
    required this.userId,
    required this.skillId,
    required this.levelReached,
    required this.lessonPosition,
    required this.lastPracticed,
    required this.completionPercentage,
  });

  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    return UserProgressModel(
      userId: json['userId'] as String,
      skillId: json['skillId'] as String,
      levelReached: json['levelReached'] as int,
      lessonPosition: json['lessonPosition'] as int,
      lastPracticed: json['lastPracticed'] != null
          ? DateTime.parse(json['lastPracticed'] as String)
          : DateTime(1999, 9, 9),
      completionPercentage: json['completionPercentage'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'skillId': skillId,
      'levelReached': levelReached,
      'lessonPosition': lessonPosition,
      'lastPracticed': lastPracticed.toIso8601String(),
      'completionPercentage': completionPercentage,
    };
  }
}
