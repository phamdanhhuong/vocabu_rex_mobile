import 'package:vocabu_rex_mobile/feed/data/models/feed_post_model.dart';

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

