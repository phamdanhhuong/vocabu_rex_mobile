import 'package:dio/dio.dart';
import 'package:vocabu_rex_mobile/network/api_constants.dart';
import 'package:vocabu_rex_mobile/network/base_api_service.dart';
import '../models/feed_post_model.dart';

class FeedService extends BaseApiService {
  // Singleton pattern
  static final FeedService _instance = FeedService._internal();
  factory FeedService() => _instance;
  FeedService._internal();

  // ==================== Feed Posts ====================

  Future<List<FeedPostModel>> getFeed({int limit = 20, int offset = 0}) async {
    try {
      final response = await client.get(
        ApiEndpoints.feed,
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );
      final data = response.data['data'] as List<dynamic>;
      return data.map((json) => FeedPostModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<List<FeedPostModel>> getUserPosts(String userId, {int limit = 20, int offset = 0}) async {
    try {
      final response = await client.get(
        ApiEndpoints.userPosts(userId),
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );
      final data = response.data['data'] as List<dynamic>;
      return data.map((json) => FeedPostModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await client.delete(ApiEndpoints.deletePost(postId));
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  // ==================== Reactions ====================

  Future<Map<String, dynamic>> toggleReaction(String postId, String reactionType) async {
    try {
      final response = await client.post(
        ApiEndpoints.postReactions(postId),
        data: {'reactionType': reactionType},
      );
      return response.data;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<List<dynamic>> getPostReactions(String postId) async {
    try {
      final response = await client.get(ApiEndpoints.postReactions(postId));
      return response.data['data'] as List<dynamic>;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  // ==================== Comments ====================

  Future<FeedCommentModel> addComment(String postId, String content) async {
    try {
      final response = await client.post(
        ApiEndpoints.postComments(postId),
        data: {'content': content},
      );
      return FeedCommentModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<List<FeedCommentModel>> getPostComments(String postId, {int limit = 20, int offset = 0}) async {
    try {
      final response = await client.get(
        ApiEndpoints.postComments(postId),
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );
      final data = response.data['data'] as List<dynamic>;
      return data.map((json) => FeedCommentModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<FeedCommentModel> updateComment(String commentId, String content) async {
    try {
      final response = await client.put(
        ApiEndpoints.comment(commentId),
        data: {'content': content},
      );
      return FeedCommentModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await client.delete(ApiEndpoints.comment(commentId));
    } on DioException catch (error) {
      throw handleError(error);
    }
  }
}
