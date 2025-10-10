import 'package:vocabu_rex_mobile/profile/data/models/profile_model.dart';
import 'package:vocabu_rex_mobile/profile/domain/entities/profile_entity.dart';

abstract class ProfileDataSource {
  Future<ProfileModel> fetchProfile();
  Future<void> followUser(String userId);
  Future<void> unfollowUser(String userId);
  Future<void> updateProfile(ProfileEntity profile);
}
