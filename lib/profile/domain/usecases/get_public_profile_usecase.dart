import 'package:vocabu_rex_mobile/profile/domain/entities/public_profile_entity.dart';
import 'package:vocabu_rex_mobile/profile/domain/repositories/profile_repository.dart';

class GetPublicProfileUsecase {
  final ProfileRepository repository;

  GetPublicProfileUsecase(this.repository);

  Future<PublicProfileEntity> call(String userId) async {
    return await repository.getPublicProfile(userId);
  }
}
