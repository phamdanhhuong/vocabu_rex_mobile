import 'package:vocabu_rex_mobile/profile/domain/entities/profile_entity.dart';
import 'package:vocabu_rex_mobile/profile/domain/repositories/profile_repository.dart';

class GetProfileUsecase {
  final ProfileRepository repository;
  
  GetProfileUsecase({required this.repository});

  Future<ProfileEntity> call() {
    return repository.getProfile();
  }
}
