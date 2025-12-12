import 'package:dio/dio.dart';
import 'package:vocabu_rex_mobile/feed/data/datasources/feed_datasource.dart';
import 'package:vocabu_rex_mobile/network/api_constants.dart';
import 'package:vocabu_rex_mobile/network/base_api_service.dart';

class FeedDataSourceImpl extends BaseApiService implements FeedDataSource {
  // Singleton pattern
  static final FeedDataSourceImpl _instance = FeedDataSourceImpl._internal();
  factory FeedDataSourceImpl() => _instance;
  FeedDataSourceImpl._internal();

  @override
  Future<Map<String, dynamic>> getFeedPosts({
    required int page,
    required int limit,
  }) async {
    try {
      final offset = (page - 1) * limit;
      final response = await client.get(
        ApiEndpoints.feed,
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  @override
  Future<void> toggleReaction({
    required String postId,
    required String reactionType,
  }) async {
    try {
      await client.post(
        ApiEndpoints.postReactions(postId),
        data: {'reactionType': reactionType},
      );
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  @override
  Future<List<dynamic>> getPostReactions({
    required String postId,
    String? reactionType,
  }) async {
    try {
      final response = await client.get(
        ApiEndpoints.postReactions(postId),
        queryParameters: reactionType != null 
            ? {'reactionType': reactionType}
            : null,
      );
      return response.data['data'] as List<dynamic>;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  @override
  Future<Map<String, dynamic>> addComment({
    required String postId,
    required String content,
  }) async {
    try {
      final response = await client.post(
        ApiEndpoints.postComments(postId),
        data: {'content': content},
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  @override
  Future<List<dynamic>> getPostComments({
    required String postId,
    required int page,
    required int limit,
  }) async {
    try {
      final offset = (page - 1) * limit;
      final response = await client.get(
        ApiEndpoints.postComments(postId),
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );
      return response.data['data'] as List<dynamic>;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  @override
  Future<void> deleteComment(String commentId) async {
    try {
      await client.delete(ApiEndpoints.comment(commentId));
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  @override
  Future<void> updateComment({
    required String commentId,
    required String content,
  }) async {
    try {
      // Server expects PUT for updating comments
      await client.put(
        ApiEndpoints.comment(commentId),
        data: {'content': content},
      );
    } on DioException catch (error) {
      throw handleError(error);
    }
  }
}
