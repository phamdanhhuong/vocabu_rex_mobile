import 'package:vocabu_rex_mobile/friend/domain/repositories/friend_repository.dart';

class UnfollowUserUsecase {
  final FriendRepository repository;
  
  UnfollowUserUsecase({required this.repository});

  Future<void> call(String userId) {
    return repository.unfollowUser(userId);
  }
}
