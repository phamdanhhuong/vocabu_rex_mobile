import 'package:vocabu_rex_mobile/feed/data/models/reaction_detail_model.dart';
import 'package:vocabu_rex_mobile/feed/domain/entities/feed_user_entity.dart';

class FeedReactionEntity {
  final String userId;
  final String reactionType;
  final DateTime createdAt;
  final FeedUserEntity user;

  FeedReactionEntity({
    required this.userId,
    required this.reactionType,
    required this.createdAt,
    required this.user,
  });

  factory FeedReactionEntity.fromModel(ReactionDetailModel model) {
    return FeedReactionEntity(
      userId: model.userId,
      reactionType: model.reactionType,
      createdAt: model.createdAt,
      user: FeedUserEntity.fromModel(model.user),
    );
  }
}
