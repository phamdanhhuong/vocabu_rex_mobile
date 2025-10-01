import 'package:vocabu_rex_mobile/home/data/models/user_progress_model.dart';

class UserProgressEntity {
  final String userId;
  final String skillId;
  final int levelReached;
  final int lessonPosition;
  final DateTime lastPracticed;
  final int completionPercentage;

  UserProgressEntity({
    required this.userId,
    required this.skillId,
    required this.levelReached,
    required this.lessonPosition,
    required this.lastPracticed,
    required this.completionPercentage,
  });

  factory UserProgressEntity.fromModel(UserProgressModel model) {
    return UserProgressEntity(
      userId: model.userId,
      skillId: model.skillId,
      levelReached: model.levelReached,
      lessonPosition: model.lessonPosition,
      lastPracticed: model.lastPracticed,
      completionPercentage: model.completionPercentage,
    );
  }

  UserProgressEntity copyWith({
    String? userId,
    String? skillId,
    int? levelReached,
    int? lessonPosition,
    DateTime? lastPracticed,
    int? completionPercentage,
  }) {
    return UserProgressEntity(
      userId: userId ?? this.userId,
      skillId: skillId ?? this.skillId,
      levelReached: levelReached ?? this.levelReached,
      lessonPosition: lessonPosition ?? this.lessonPosition,
      lastPracticed: lastPracticed ?? this.lastPracticed,
      completionPercentage: completionPercentage ?? this.completionPercentage,
    );
  }
}
