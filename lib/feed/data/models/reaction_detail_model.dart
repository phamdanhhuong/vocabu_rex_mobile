class ReactionDetailModel {
  final String userId;
  final String reactionType;
  final DateTime createdAt;
  final FeedUserModel user;

  ReactionDetailModel({
    required this.userId,
    required this.reactionType,
    required this.createdAt,
    required this.user,
  });

  factory ReactionDetailModel.fromJson(Map<String, dynamic> json) {
    return ReactionDetailModel(
      userId: json['userId'] as String,
      reactionType: json['reactionType'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      user: FeedUserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'reactionType': reactionType,
      'createdAt': createdAt.toIso8601String(),
      'user': user.toJson(),
    };
  }
}

class FeedUserModel {
  final String id;
  final String? username;
  final String? fullName;
  final String? profilePictureUrl;
  final int currentLevel;

  FeedUserModel({
    required this.id,
    this.username,
    this.fullName,
    this.profilePictureUrl,
    this.currentLevel = 0,
  });

  factory FeedUserModel.fromJson(Map<String, dynamic> json) {
    return FeedUserModel(
      id: json['id'] as String,
      username: json['username'] as String?,
      fullName: json['fullName'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      currentLevel: json['currentLevel'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'profilePictureUrl': profilePictureUrl,
      'currentLevel': currentLevel,
    };
  }

  String get displayName => fullName ?? username ?? 'User';
}
