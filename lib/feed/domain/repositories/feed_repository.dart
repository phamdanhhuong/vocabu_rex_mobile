import 'package:vocabu_rex_mobile/feed/domain/entities/feed_post_entity.dart';
import 'package:vocabu_rex_mobile/feed/domain/entities/feed_comment_entity.dart';
import 'package:vocabu_rex_mobile/feed/domain/entities/feed_reaction_entity.dart';

abstract class FeedRepository {
  /// Get paginated feed posts
  Future<List<FeedPostEntity>> getFeedPosts({
    required int page,
    required int limit,
  });

  /// Toggle reaction on a post
  Future<void> toggleReaction({
    required String postId,
    required String reactionType,
  });

  /// Get reactions for a specific post
  Future<List<FeedReactionEntity>> getPostReactions({
    required String postId,
    String? reactionType,
  });

  /// Add comment to a post
  Future<void> addComment({
    required String postId,
    required String content,
  });

  /// Get comments for a specific post
  Future<List<FeedCommentEntity>> getPostComments({
    required String postId,
    required int page,
    required int limit,
  });

  /// Delete a comment
  Future<void> deleteComment(String commentId);

  /// Update a comment
  Future<void> updateComment({
    required String commentId,
    required String content,
  });
}
