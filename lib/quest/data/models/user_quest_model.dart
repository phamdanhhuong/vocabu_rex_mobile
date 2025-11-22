import 'package:vocabu_rex_mobile/quest/data/models/quest_model.dart';

class UserQuestModel {
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
  final QuestModel quest;

  UserQuestModel({
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

  factory UserQuestModel.fromJson(Map<String, dynamic> json) {
    return UserQuestModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      questId: json['questId'] as String,
      progress: json['progress'] as int,
      requirement: json['requirement'] as int,
      status: json['status'] as String,
      difficultyLevel: json['difficultyLevel'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String) 
          : null,
      claimedAt: json['claimedAt'] != null 
          ? DateTime.parse(json['claimedAt'] as String) 
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      quest: QuestModel.fromJson(json['quest'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'questId': questId,
      'progress': progress,
      'requirement': requirement,
      'status': status,
      'difficultyLevel': difficultyLevel,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'claimedAt': claimedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'quest': quest.toJson(),
    };
  }
}
