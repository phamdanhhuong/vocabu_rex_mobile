import 'package:vocabu_rex_mobile/profile/data/datasources/profile_datasource.dart';
import 'package:vocabu_rex_mobile/profile/domain/entities/profile_entity.dart';
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
}
