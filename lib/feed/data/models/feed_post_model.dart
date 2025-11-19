class FeedPostModel {
  final String id;
  final String userId;
  final String postType;
  final String content;
  final Map<String, dynamic>? metadata;
  final String? imageUrl;
  final bool isVisible;
  final DateTime createdAt;
  final DateTime updatedAt;
  final FeedUserModel user;
  final List<FeedReactionSummary> reactions;
  final int commentCount;
  final String? userReaction;

  FeedPostModel({
    required this.id,
    required this.userId,
    required this.postType,
    required this.content,
    this.metadata,
    this.imageUrl,
    required this.isVisible,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.reactions,
    required this.commentCount,
    this.userReaction,
  });

  factory FeedPostModel.fromJson(Map<String, dynamic> json) {
    return FeedPostModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      postType: json['postType'] as String,
      content: json['content'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
      imageUrl: json['imageUrl'] as String?,
      isVisible: json['isVisible'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      user: FeedUserModel.fromJson(json['user'] as Map<String, dynamic>),
      reactions: (json['reactions'] as List<dynamic>?)
              ?.map((e) => FeedReactionSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      commentCount: json['commentCount'] as int,
      userReaction: json['userReaction'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'postType': postType,
      'content': content,
      'metadata': metadata,
      'imageUrl': imageUrl,
      'isVisible': isVisible,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'user': user.toJson(),
      'reactions': reactions.map((e) => e.toJson()).toList(),
      'commentCount': commentCount,
      'userReaction': userReaction,
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
    required this.currentLevel,
  });

  factory FeedUserModel.fromJson(Map<String, dynamic> json) {
    return FeedUserModel(
      id: json['id'] as String,
      username: json['username'] as String?,
      fullName: json['fullName'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      currentLevel: json['currentLevel'] as int,
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

class FeedReactionSummary {
  final String reactionType;
  final int count;

  FeedReactionSummary({
    required this.reactionType,
    required this.count,
  });

  factory FeedReactionSummary.fromJson(Map<String, dynamic> json) {
    return FeedReactionSummary(
      reactionType: json['reactionType'] as String,
      count: json['count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reactionType': reactionType,
      'count': count,
    };
  }
}

class FeedCommentModel {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final bool isEdited;
  final DateTime createdAt;
  final DateTime updatedAt;
  final FeedUserModel user;

  FeedCommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.isEdited,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory FeedCommentModel.fromJson(Map<String, dynamic> json) {
    return FeedCommentModel(
      id: json['id'] as String,
      postId: json['postId'] as String,
      userId: json['userId'] as String,
      content: json['content'] as String,
      isEdited: json['isEdited'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      user: FeedUserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'content': content,
      'isEdited': isEdited,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'user': user.toJson(),
    };
  }
}
