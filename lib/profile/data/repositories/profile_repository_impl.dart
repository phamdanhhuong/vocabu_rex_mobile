import 'package:vocabu_rex_mobile/profile/data/datasources/profile_datasource.dart';
import 'package:vocabu_rex_mobile/profile/domain/entities/profile_entity.dart';
import 'package:vocabu_rex_mobile/profile/domain/entities/public_profile_entity.dart';
import 'package:vocabu_rex_mobile/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDataSource profileDataSource;

  ProfileRepositoryImpl({required this.profileDataSource});

  @override
  Future<ProfileEntity> getProfile() async {
    final model = await profileDataSource.fetchProfile();
    return ProfileEntity.fromModel(model);
  }

  @override
  Future<PublicProfileEntity> getPublicProfile(String userId) async {
    final model = await profileDataSource.fetchPublicProfile(userId);
    return model.toEntity();
  }

  @override
  Future<void> followUser(String userId) async {
    await profileDataSource.followUser(userId);
  }

  @override
  Future<void> unfollowUser(String userId) async {
    await profileDataSource.unfollowUser(userId);
  }

  @override
  Future<void> updateProfile(ProfileEntity profile) async {
    await profileDataSource.updateProfile(profile);
  }

  @override
  Future<void> reportUser(String userId, String reason, String? description) async {
    await profileDataSource.reportUser(userId, reason, description);
  }

  @override
  Future<void> blockUser(String userId) async {
    await profileDataSource.blockUser(userId);
  }

  @override
  Future<void> unblockUser(String userId) async {
    await profileDataSource.unblockUser(userId);
  }
}
