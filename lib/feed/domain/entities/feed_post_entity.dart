import 'package:vocabu_rex_mobile/feed/data/models/feed_post_model.dart';
import 'package:vocabu_rex_mobile/feed/domain/entities/feed_user_entity.dart';
import 'package:vocabu_rex_mobile/feed/domain/entities/feed_comment_entity.dart';
import 'package:vocabu_rex_mobile/feed/domain/entities/feed_reaction_summary_entity.dart';

class FeedPostEntity {
  final String id;
  final String userId;
  final String postType;
  final String content;
  final Map<String, dynamic>? metadata;
  final String? imageUrl;
  final bool isVisible;
  final DateTime createdAt;
  final DateTime updatedAt;
  final FeedUserEntity user;
  final List<FeedReactionSummaryEntity> reactions;
  final int commentCount;
  final String? userReaction;
  final FeedCommentEntity? latestComment;

  FeedPostEntity({
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
    this.latestComment,
  });

  factory FeedPostEntity.fromModel(FeedPostModel model) {
    return FeedPostEntity(
      id: model.id,
      userId: model.userId,
      postType: model.postType,
      content: model.content,
      metadata: model.metadata,
      imageUrl: model.imageUrl,
      isVisible: model.isVisible,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      user: FeedUserEntity.fromModel(model.user),
      reactions: model.reactions
          .map((r) => FeedReactionSummaryEntity.fromModel(r))
          .toList(),
      commentCount: model.commentCount,
      userReaction: model.userReaction,
      latestComment: model.latestComment != null
          ? FeedCommentEntity.fromModel(model.latestComment!)
          : null,
    );
  }

  FeedPostEntity copyWith({
    String? id,
    String? userId,
    String? postType,
    String? content,
    Map<String, dynamic>? metadata,
    String? imageUrl,
    bool? isVisible,
    DateTime? createdAt,
    DateTime? updatedAt,
    FeedUserEntity? user,
    List<FeedReactionSummaryEntity>? reactions,
    int? commentCount,
    String? userReaction,
    FeedCommentEntity? latestComment,
    bool clearUserReaction = false,
  }) {
    return FeedPostEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      postType: postType ?? this.postType,
      content: content ?? this.content,
      metadata: metadata ?? this.metadata,
      imageUrl: imageUrl ?? this.imageUrl,
      isVisible: isVisible ?? this.isVisible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      reactions: reactions ?? this.reactions,
      commentCount: commentCount ?? this.commentCount,
      userReaction: clearUserReaction ? null : (userReaction ?? this.userReaction),
      latestComment: latestComment ?? this.latestComment,
    );
  }
}
