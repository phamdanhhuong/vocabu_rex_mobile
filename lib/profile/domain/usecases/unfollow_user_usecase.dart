import 'package:vocabu_rex_mobile/profile/data/service/profile_service.dart';

class UnfollowUserUsecase {
  final ProfileService _profileService;

  UnfollowUserUsecase(this._profileService);

  Future<void> call(String userId) async {
    await _profileService.unfollowUser(userId);
  }
}
