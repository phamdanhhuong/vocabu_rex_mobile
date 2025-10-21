import 'package:vocabu_rex_mobile/exercise/domain/entities/reward_entity.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/bonuses_entity.dart';

class SubmitResponseEntity {
  final String lessonId;
  final String skillId;
  final int totalExercises;
  final int correctExercises;
  final double accuracy;
  final int wordMasteriesUpdated;
  final int grammarMasteriesUpdated;
  final bool isLessonSuccessful;
  final String message;
  final int xpEarned;
  final BonusesEntity bonuses; // baseXP, bonusXP, perfectBonusXP
  final bool isPerfect;
  final List<RewardEntity> rewards;
  final String? skillProgressMessage;

  SubmitResponseEntity({
    required this.lessonId,
    required this.skillId,
    required this.totalExercises,
    required this.correctExercises,
    required this.accuracy,
    required this.wordMasteriesUpdated,
    required this.grammarMasteriesUpdated,
    required this.isLessonSuccessful,
    required this.message,
    required this.xpEarned,
    required this.bonuses,
    required this.isPerfect,
    required this.rewards,
    this.skillProgressMessage,
  });

  factory SubmitResponseEntity.fromJson(Map<String, dynamic> json) {
    return SubmitResponseEntity(
      lessonId: json['lessonId'] as String,
      skillId: json['skillId'] as String,
      totalExercises: json['totalExercises'] as int,
      correctExercises: json['correctExercises'] as int,
      accuracy: (json['accuracy'] as num).toDouble(),
      wordMasteriesUpdated: json['wordMasteriesUpdated'] as int,
      grammarMasteriesUpdated: json['grammarMasteriesUpdated'] as int,
      isLessonSuccessful: json['isLessonSuccessful'] as bool,
      message: json['message'] as String,
  xpEarned: (json['xpEarned'] ?? 0) as int,
  bonuses: json['bonuses'] != null ? BonusesEntity.fromJson(Map<String, dynamic>.from(json['bonuses'])) : BonusesEntity(baseXP: 0, bonusXP: 0, perfectBonusXP: 0),
  isPerfect: json['isPerfect'] ?? false,
  rewards: (json['rewards'] as List?)?.map((e) => RewardEntity.fromJson(Map<String, dynamic>.from(e as Map))).toList() ?? [],
      skillProgressMessage: json['skillProgressMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'skillId': skillId,
      'totalExercises': totalExercises,
      'correctExercises': correctExercises,
      'accuracy': accuracy,
      'wordMasteriesUpdated': wordMasteriesUpdated,
      'grammarMasteriesUpdated': grammarMasteriesUpdated,
      'isLessonSuccessful': isLessonSuccessful,
      'message': message,
      'xpEarned': xpEarned,
  'bonuses': bonuses.toJson(),
  'isPerfect': isPerfect,
  'rewards': rewards.map((r) => r.toJson()).toList(),
      'skillProgressMessage': skillProgressMessage,
    };
  }
}
