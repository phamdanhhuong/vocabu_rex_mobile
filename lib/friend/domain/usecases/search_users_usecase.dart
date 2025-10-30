import 'package:vocabu_rex_mobile/friend/domain/entities/user_entity.dart';
import 'package:vocabu_rex_mobile/friend/domain/repositories/friend_repository.dart';

class SearchUsersUsecase {
  final FriendRepository repository;
  
  SearchUsersUsecase({required this.repository});

  Future<List<UserEntity>> call(String query) {
    return repository.searchUsersByName(query);
  }
}
