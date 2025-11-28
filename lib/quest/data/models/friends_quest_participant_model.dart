class FriendsQuestParticipantModel {
  final String id;
  final String questKey;
  final String userId;
  final DateTime weekStartDate;
  final int contribution;
  final bool isCreator;
  final DateTime joinedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ParticipantUserModel? user;

  FriendsQuestParticipantModel({
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

  factory FriendsQuestParticipantModel.fromJson(Map<String, dynamic> json) {
    return FriendsQuestParticipantModel(
      id: json['id'] as String,
      questKey: json['questKey'] as String,
      userId: json['userId'] as String,
      weekStartDate: DateTime.parse(json['weekStartDate'] as String),
      contribution: json['contribution'] as int,
      isCreator: json['isCreator'] as bool,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      user: json['user'] != null
          ? ParticipantUserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questKey': questKey,
      'userId': userId,
      'weekStartDate': weekStartDate.toIso8601String(),
      'contribution': contribution,
      'isCreator': isCreator,
      'joinedAt': joinedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'user': user?.toJson(),
    };
  }
}

class ParticipantUserModel {
  final String? username;
  final String? fullName;
  final String? profilePictureUrl;

  ParticipantUserModel({
    this.username,
    this.fullName,
    this.profilePictureUrl,
  });

  factory ParticipantUserModel.fromJson(Map<String, dynamic> json) {
    return ParticipantUserModel(
      username: json['username'] as String?,
      fullName: json['fullName'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'fullName': fullName,
      'profilePictureUrl': profilePictureUrl,
    };
  }
}
