import 'package:vocabu_rex_mobile/profile/domain/entities/profile_entity.dart';
import 'package:vocabu_rex_mobile/profile/domain/entities/public_profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile();
  Future<PublicProfileEntity> getPublicProfile(String userId);
  Future<void> followUser(String userId);
  Future<void> unfollowUser(String userId);
  Future<void> updateProfile(ProfileEntity profile);
  Future<void> reportUser(String userId, String reason, String? description);
  Future<void> blockUser(String userId);
  Future<void> unblockUser(String userId);
}
