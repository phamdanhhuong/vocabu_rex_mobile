import 'package:vocabu_rex_mobile/profile/domain/entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile();
  Future<void> followUser(String userId);
  Future<void> unfollowUser(String userId);
  Future<void> updateProfile(ProfileEntity profile);
}
