import 'package:dio/dio.dart';
import 'package:vocabu_rex_mobile/network/api_constants.dart';
import 'package:vocabu_rex_mobile/network/base_api_service.dart';

class QuestService extends BaseApiService {
  // Singleton pattern
  static final QuestService _instance = QuestService._internal();
  factory QuestService() => _instance;
  QuestService._internal();

  Future<List<dynamic>> getUserQuests({bool activeOnly = false}) async {
    try {
      final response = await client.get(
        ApiEndpoints.quests,
        queryParameters: activeOnly ? {'active': 'true'} : null,
      );
      return response.data["data"] as List<dynamic>;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<List<dynamic>> getCompletedQuests() async {
    try {
      final response = await client.get(ApiEndpoints.questsCompleted);
      return response.data["data"] as List<dynamic>;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<Map<String, dynamic>> claimQuest(String questId) async {
    try {
      final response = await client.post(ApiEndpoints.claimQuest(questId));
      return response.data["data"] as Map<String, dynamic>;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<List<dynamic>> getUnlockedChests() async {
    try {
      final response = await client.get(ApiEndpoints.questChests);
      return response.data["data"] as List<dynamic>;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<Map<String, dynamic>> openChest(String chestId) async {
    try {
      final response = await client.post(ApiEndpoints.openChest(chestId));
      return response.data["data"] as Map<String, dynamic>;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<List<dynamic>> getFriendsQuestParticipants(
      String questKey, DateTime weekStartDate) async {
    try {
      final response = await client.get(
        ApiEndpoints.getFriendsQuestParticipants(questKey),
        queryParameters: {
          'weekStartDate': weekStartDate.toIso8601String(),
        },
      );
      return response.data["data"] as List<dynamic>;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<Map<String, dynamic>> joinFriendsQuest(
      String questKey, DateTime weekStartDate, {bool isCreator = false}) async {
    try {
      final response = await client.post(
        ApiEndpoints.joinFriendsQuest(questKey),
        data: {
          'weekStartDate': weekStartDate.toIso8601String(),
          'isCreator': isCreator,
        },
      );
      return response.data["data"] as Map<String, dynamic>;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  Future<Map<String, dynamic>> inviteFriendToQuest(
      String questKey, String friendId, DateTime weekStartDate) async {
    try {
      final response = await client.post(
        ApiEndpoints.inviteFriendToQuest(questKey),
        data: {
          'friendId': friendId,
          'weekStartDate': weekStartDate.toIso8601String(),
        },
      );
      return response.data["data"] as Map<String, dynamic>;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }
}
