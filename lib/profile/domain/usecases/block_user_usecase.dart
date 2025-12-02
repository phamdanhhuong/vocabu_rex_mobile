import 'package:vocabu_rex_mobile/profile/domain/repositories/profile_repository.dart';

class BlockUserUsecase {
  final ProfileRepository repository;

  BlockUserUsecase(this.repository);

  Future<void> call(String userId) async {
    return await repository.blockUser(userId);
  }
}
