import 'package:vocabu_rex_mobile/friend/data/models/user_model.dart';

abstract class FriendDataSource {
  Future<List<UserModel>> searchUsers(String query);
  Future<List<UserModel>> getSuggestedFriends();
  Future<void> followUser(String userId);
  Future<void> unfollowUser(String userId);
}
