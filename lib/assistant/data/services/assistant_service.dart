import 'package:dio/dio.dart';
import 'package:vocabu_rex_mobile/core/token_manager.dart';
import 'package:vocabu_rex_mobile/network/api_constants.dart';
import 'package:vocabu_rex_mobile/network/base_api_service.dart';

class AssistantService extends BaseApiService {
  // Singleton pattern
  static final AssistantService _instance = AssistantService._internal();
  factory AssistantService() => _instance;
  AssistantService._internal();

  Future<Map<String, dynamic>> start() async {
    try {
      final userInfo = await TokenManager.getUserInfo();

      final response = await client.post(
        ApiEndpoints.startChat,
        data: {
          "user_id": userInfo["userId"],
          "initial_message": "string",
          "role": "vocabulary_expert",
          "context": {},
        },
      );

      return response.data["data"];
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<Map<String, dynamic>> chat({
    required String conversationId,
    required String message,
    String? role,
  }) async {
    try {
      final userInfo = await TokenManager.getUserInfo();

      final response = await client.post(
        ApiEndpoints.chat,
        data: {
          "message": message,
          "conversation_id": conversationId,
          "user_id": userInfo["userId"],
          "role": role ?? "vocabulary_expert",
          "context": {},
        },
      );

      return response.data["data"];
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<List<dynamic>> getUserConversations() async {
    try {
      final response = await client.get(
        ApiEndpoints.getUserConversations,
      );

      return response.data["data"] as List<dynamic>;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<Map<String, dynamic>> getConversationHistory(String conversationId) async {
    try {
      final response = await client.get(
        '${ApiEndpoints.getConversationHistory}/$conversationId/history',
      );

      print('=== Conversation History Response ===');
      print('Full response: ${response.data}');
      
      // Handle both wrapped and unwrapped responses
      if (response.data is Map<String, dynamic>) {
        if (response.data.containsKey("data")) {
          print('Using wrapped data field');
          return response.data["data"];
        } else {
          print('Using direct response');
          return response.data;
        }
      }
      
      throw Exception('Invalid response format');
    } on DioException catch (error) {
      throw handleError(error);
    }
  }
}
