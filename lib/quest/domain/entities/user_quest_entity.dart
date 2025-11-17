import 'package:vocabu_rex_mobile/quest/data/models/user_quest_model.dart';
import 'package:vocabu_rex_mobile/quest/domain/entities/quest_entity.dart';

class UserQuestEntity {
  final String id;
  final String userId;
  final String questId;
  final int progress;
  final int requirement;
  final String status;
  final String difficultyLevel;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? completedAt;
  final DateTime? claimedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final QuestEntity quest;

  UserQuestEntity({
    required this.id,
    required this.userId,
    required this.questId,
    required this.progress,
    required this.requirement,
    required this.status,
    required this.difficultyLevel,
    required this.startDate,
    required this.endDate,
    this.completedAt,
    this.claimedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.quest,
  });

  factory UserQuestEntity.fromModel(UserQuestModel model) {
    return UserQuestEntity(
      id: model.id,
      userId: model.userId,
      questId: model.questId,
      progress: model.progress,
      requirement: model.requirement,
      status: model.status,
      difficultyLevel: model.difficultyLevel,
      startDate: model.startDate,
      endDate: model.endDate,
      completedAt: model.completedAt,
      claimedAt: model.claimedAt,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      quest: QuestEntity.fromModel(model.quest),
    );
  }

  bool get isCompleted => status == 'COMPLETED' || status == 'CLAIMED';
  bool get isClaimed => status == 'CLAIMED';
  bool get canClaim => status == 'COMPLETED' && !isClaimed;
  double get progressPercentage => 
      requirement > 0 ? (progress / requirement).clamp(0.0, 1.0) : 0.0;
}
