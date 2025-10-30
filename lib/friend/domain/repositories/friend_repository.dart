import 'package:vocabu_rex_mobile/friend/domain/entities/user_entity.dart';

abstract class FriendRepository {
  Future<List<UserEntity>> searchUsersByName(String query);
  Future<List<UserEntity>> getSuggestedFriends();
  Future<void> followUser(String userId);
  Future<void> unfollowUser(String userId);
}
