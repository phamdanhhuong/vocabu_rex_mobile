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
    // Convert domain entity to data model JSON before sending to service
    final model = ProfileModel(
      id: profile.id,
      username: profile.username,
      displayName: profile.displayName,
      avatarUrl: profile.avatarUrl,
      joinedDate: profile.joinedDate,
      countryCode: profile.countryCode,
      followingCount: profile.followingCount,
      followerCount: profile.followerCount,
      streakDays: profile.streakDays,
      totalExp: profile.totalExp,
      isInTournament: profile.isInTournament,
      top3Count: profile.top3Count,
    );

    await profileService.updateProfile(model.toJson());
  }
}
