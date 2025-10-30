import 'package:vocabu_rex_mobile/friend/data/datasources/friend_datasource.dart';
import 'package:vocabu_rex_mobile/friend/domain/entities/user_entity.dart';
import 'package:vocabu_rex_mobile/friend/domain/repositories/friend_repository.dart';

class FriendRepositoryImpl implements FriendRepository {
  final FriendDataSource friendDataSource;

  FriendRepositoryImpl({required this.friendDataSource});

  @override
  Future<List<UserEntity>> searchUsersByName(String query) async {
    final models = await friendDataSource.searchUsers(query);
    return models.map((model) => UserEntity.fromModel(model)).toList();
  }

  @override
  Future<List<UserEntity>> getSuggestedFriends() async {
    final models = await friendDataSource.getSuggestedFriends();
    return models.map((model) => UserEntity.fromModel(model)).toList();
  }

  @override
  Future<void> followUser(String userId) async {
    await friendDataSource.followUser(userId);
  }

  @override
  Future<void> unfollowUser(String userId) async {
    await friendDataSource.unfollowUser(userId);
  }
}
