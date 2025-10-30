import 'package:vocabu_rex_mobile/friend/domain/repositories/friend_repository.dart';

class FollowUserUsecase {
  final FriendRepository repository;
  
  FollowUserUsecase({required this.repository});

  Future<void> call(String userId) {
    return repository.followUser(userId);
  }
}
