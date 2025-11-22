import 'package:vocabu_rex_mobile/feed/data/models/feed_post_model.dart';
import 'package:vocabu_rex_mobile/feed/domain/entities/feed_user_entity.dart';

class FeedCommentEntity {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final bool isEdited;
  final DateTime createdAt;
  final DateTime updatedAt;
  final FeedUserEntity user;

  FeedCommentEntity({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.isEdited,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory FeedCommentEntity.fromModel(FeedCommentModel model) {
    return FeedCommentEntity(
      id: model.id,
      postId: model.postId,
      userId: model.userId,
      content: model.content,
      isEdited: model.isEdited,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      user: FeedUserEntity.fromModel(model.user),
    );
  }
}
