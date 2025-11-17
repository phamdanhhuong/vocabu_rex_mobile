import 'package:vocabu_rex_mobile/quest/domain/entities/user_quest_entity.dart';

// States
abstract class QuestState {}

class QuestInitial extends QuestState {}

class QuestLoading extends QuestState {}

class QuestLoaded extends QuestState {
  final List<UserQuestEntity> quests;
  final List<UserQuestEntity> dailyQuests;
  final List<UserQuestEntity> friendsQuests;
  final List<UserQuestEntity> monthlyBadgeQuests;
  final int completedToday;
  final int totalDaily;

  QuestLoaded({
    required this.quests,
    required this.dailyQuests,
    required this.friendsQuests,
    required this.monthlyBadgeQuests,
    required this.completedToday,
    required this.totalDaily,
  });

  QuestLoaded copyWith({
    List<UserQuestEntity>? quests,
    List<UserQuestEntity>? dailyQuests,
    List<UserQuestEntity>? friendsQuests,
    List<UserQuestEntity>? monthlyBadgeQuests,
    int? completedToday,
    int? totalDaily,
  }) {
    return QuestLoaded(
      quests: quests ?? this.quests,
      dailyQuests: dailyQuests ?? this.dailyQuests,
      friendsQuests: friendsQuests ?? this.friendsQuests,
      monthlyBadgeQuests: monthlyBadgeQuests ?? this.monthlyBadgeQuests,
      completedToday: completedToday ?? this.completedToday,
      totalDaily: totalDaily ?? this.totalDaily,
    );
  }
}

class QuestClaiming extends QuestState {
  final List<UserQuestEntity> quests;
  final String claimingQuestId;

  QuestClaiming({required this.quests, required this.claimingQuestId});
}

class QuestError extends QuestState {
  final String message;
  QuestError(this.message);
}
