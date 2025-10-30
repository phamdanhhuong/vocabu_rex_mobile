import 'package:vocabu_rex_mobile/friend/domain/entities/user_entity.dart';
import 'package:vocabu_rex_mobile/friend/domain/repositories/friend_repository.dart';

class GetSuggestedFriendsUsecase {
  final FriendRepository repository;
  
  GetSuggestedFriendsUsecase({required this.repository});

  Future<List<UserEntity>> call() {
    return repository.getSuggestedFriends();
  }
}
