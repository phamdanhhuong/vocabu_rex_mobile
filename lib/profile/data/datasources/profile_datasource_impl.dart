import 'package:vocabu_rex_mobile/profile/data/datasources/profile_datasource.dart';
import 'package:vocabu_rex_mobile/profile/data/models/profile_model.dart';
import 'package:vocabu_rex_mobile/profile/data/service/profile_service.dart';
import 'package:vocabu_rex_mobile/profile/domain/entities/profile_entity.dart';

class ProfileDataSourceImpl implements ProfileDataSource {
  final ProfileService profileService;
  ProfileDataSourceImpl(this.profileService);

  @override
  Future<ProfileModel> fetchProfile() async {
    final res = await profileService.getProfile();
    final result = ProfileModel.fromJson(res);
    return result;
  }

  @override
  Future<void> followUser(String userId) async {
    await profileService.followUser(userId);
  }

  @override
  Future<void> unfollowUser(String userId) async {
    await profileService.unfollowUser(userId);
  }

  @override
  Future<void> updateProfile(ProfileEntity profile) async {
    await profileService.updateProfile(profile);
  }
}
