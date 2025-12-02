import 'package:vocabu_rex_mobile/profile/data/models/profile_model.dart';
import 'package:vocabu_rex_mobile/profile/data/models/public_profile_model.dart';
import 'package:vocabu_rex_mobile/profile/domain/entities/profile_entity.dart';

abstract class ProfileDataSource {
  Future<ProfileModel> fetchProfile();
  Future<PublicProfileModel> fetchPublicProfile(String userId);
  Future<void> followUser(String userId);
  Future<void> unfollowUser(String userId);
  Future<void> updateProfile(ProfileEntity profile);
  Future<void> reportUser(String userId, String reason, String? description);
  Future<void> blockUser(String userId);
  Future<void> unblockUser(String userId);
}
