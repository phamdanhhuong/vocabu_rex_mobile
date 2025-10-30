import 'package:vocabu_rex_mobile/friend/data/datasources/friend_datasource.dart';
import 'package:vocabu_rex_mobile/friend/data/models/user_model.dart';
import 'package:vocabu_rex_mobile/friend/data/services/friend_service.dart';

class FriendDataSourceImpl implements FriendDataSource {
  final FriendService friendService;
  FriendDataSourceImpl(this.friendService);

  @override
  Future<List<UserModel>> searchUsers(String query) async {
    final res = await friendService.searchUsers(query);
    return res.map((json) => UserModel.fromJson(json)).toList();
  }

  @override
  Future<List<UserModel>> getSuggestedFriends() async {
    final res = await friendService.getSuggestedFriends();
    return res.map((json) => UserModel.fromJson(json)).toList();
  }

  @override
  Future<void> followUser(String userId) async {
    await friendService.followUser(userId);
  }

  @override
  Future<void> unfollowUser(String userId) async {
    await friendService.unfollowUser(userId);
  }
}
