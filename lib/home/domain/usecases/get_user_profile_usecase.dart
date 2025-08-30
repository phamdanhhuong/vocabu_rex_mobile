import 'package:vocabu_rex_mobile/home/domain/entities/user_profile_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/repositories/home_repository.dart';

class GetUserProfileUsecase {
  final HomeRepository homeRepository;
  GetUserProfileUsecase({required this.homeRepository});
  Future<UserProfileEntity> call() async {
    return homeRepository.getUserProfile();
  }
}
