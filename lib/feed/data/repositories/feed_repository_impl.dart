import 'package:vocabu_rex_mobile/feed/data/datasources/feed_datasource.dart';
import 'package:vocabu_rex_mobile/feed/data/models/feed_post_model.dart';
import 'package:vocabu_rex_mobile/feed/data/models/reaction_detail_model.dart';
import 'package:vocabu_rex_mobile/feed/domain/entities/feed_comment_entity.dart';
import 'package:vocabu_rex_mobile/feed/domain/entities/feed_post_entity.dart';
import 'package:vocabu_rex_mobile/feed/domain/entities/feed_reaction_entity.dart';
import 'package:vocabu_rex_mobile/feed/domain/repositories/feed_repository.dart';

class FeedRepositoryImpl implements FeedRepository {
  final FeedDataSource dataSource;

  FeedRepositoryImpl(this.dataSource);

  @override
  Future<List<FeedPostEntity>> getFeedPosts({
    required int page,
    required int limit,
  }) async {
    final response = await dataSource.getFeedPosts(page: page, limit: limit);
    final data = response['data'] as List<dynamic>;
    final models = data
        .map((json) => FeedPostModel.fromJson(json as Map<String, dynamic>))
        .toList();
    return models.map((model) => FeedPostEntity.fromModel(model)).toList();
  }

  @override
  Future<void> toggleReaction({
    required String postId,
    required String reactionType,
  }) async {
    await dataSource.toggleReaction(postId: postId, reactionType: reactionType);
  }

  @override
  Future<List<FeedReactionEntity>> getPostReactions({
    required String postId,
    String? reactionType,
  }) async {
    final data = await dataSource.getPostReactions(
      postId: postId,
      reactionType: reactionType,
    );
    final models = data
        .map((json) => ReactionDetailModel.fromJson(json as Map<String, dynamic>))
        .toList();
    return models.map((model) => FeedReactionEntity.fromModel(model)).toList();
  }

  @override
  Future<void> addComment({
    required String postId,
    required String content,
  }) async {
    await dataSource.addComment(
      postId: postId,
      content: content,
    );
    // No need to parse response, we'll reload comments after adding
  }

  @override
  Future<List<FeedCommentEntity>> getPostComments({
    required String postId,
    required int page,
    required int limit,
  }) async {
    final data = await dataSource.getPostComments(
      postId: postId,
      page: page,
      limit: limit,
    );
    final models = data
        .map((json) => FeedCommentModel.fromJson(json as Map<String, dynamic>))
        .toList();
    return models.map((model) => FeedCommentEntity.fromModel(model)).toList();
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await dataSource.deleteComment(commentId);
  }

  @override
  Future<void> updateComment({
    required String commentId,
    required String content,
  }) async {
    await dataSource.updateComment(
      commentId: commentId,
      content: content,
    );
    // No need to parse response, we'll reload comments after updating
  }
}
