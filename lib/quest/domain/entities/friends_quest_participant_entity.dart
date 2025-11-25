import 'package:vocabu_rex_mobile/quest/data/models/friends_quest_participant_model.dart';

class FriendsQuestParticipantEntity {
  final String id;
  final String questKey;
  final String userId;
  final DateTime weekStartDate;
  final int contribution;
  final bool isCreator;
  final DateTime joinedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ParticipantUser? user;

  FriendsQuestParticipantEntity({
    required this.id,
    required this.questKey,
    required this.userId,
    required this.weekStartDate,
    required this.contribution,
    required this.isCreator,
    required this.joinedAt,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory FriendsQuestParticipantEntity.fromModel(
      FriendsQuestParticipantModel model) {
    return FriendsQuestParticipantEntity(
      id: model.id,
      questKey: model.questKey,
      userId: model.userId,
      weekStartDate: model.weekStartDate,
      contribution: model.contribution,
      isCreator: model.isCreator,
      joinedAt: model.joinedAt,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      user: model.user != null
          ? ParticipantUser.fromModel(model.user!)
          : null,
    );
  }
}

class ParticipantUser {
  final String? username;
  final String? fullName;
  final String? profilePictureUrl;

  ParticipantUser({
    this.username,
    this.fullName,
    this.profilePictureUrl,
  });

  factory ParticipantUser.fromModel(ParticipantUserModel model) {
    return ParticipantUser(
      username: model.username,
      fullName: model.fullName,
      profilePictureUrl: model.profilePictureUrl,
    );
  }

  String get displayName => fullName ?? username ?? 'Unknown User';
}
