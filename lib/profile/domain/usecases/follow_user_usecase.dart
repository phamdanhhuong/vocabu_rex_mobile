import 'package:vocabu_rex_mobile/profile/data/service/profile_service.dart';

class FollowUserUsecase {
  final ProfileService _profileService;

  FollowUserUsecase(this._profileService);

  Future<void> call(String userId) async {
    await _profileService.followUser(userId);
  }
}
