import 'package:vocabu_rex_mobile/feed/data/models/feed_post_model.dart';

class FeedUserEntity {
  final String id;
  final String? username;
  final String? fullName;
  final String? profilePictureUrl;
  final int currentLevel;

  FeedUserEntity({
    required this.id,
    this.username,
    this.fullName,
    this.profilePictureUrl,
    this.currentLevel = 0,
  });

  String get displayName => fullName ?? username ?? 'User';

  factory FeedUserEntity.fromModel(FeedUserModel model) {
    return FeedUserEntity(
      id: model.id,
      username: model.username,
      fullName: model.fullName,
      profilePictureUrl: model.profilePictureUrl,
      currentLevel: model.currentLevel,
    );
  }
}
