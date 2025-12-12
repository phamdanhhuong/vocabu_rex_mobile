abstract class FeedDataSource {
  /// Fetch paginated feed posts
  Future<Map<String, dynamic>> getFeedPosts({
    required int page,
    required int limit,
  });

  /// Toggle reaction on a post
  Future<void> toggleReaction({
    required String postId,
    required String reactionType,
  });

  /// Get reactions for a specific post
  Future<List<dynamic>> getPostReactions({
    required String postId,
    String? reactionType,
  });

  /// Add comment to a post
  Future<Map<String, dynamic>> addComment({
    required String postId,
    required String content,
  });

  /// Get comments for a specific post
  Future<List<dynamic>> getPostComments({
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
