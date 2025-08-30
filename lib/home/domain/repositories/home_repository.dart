import 'package:vocabu_rex_mobile/home/domain/entities/user_profile_entity.dart';

abstract class HomeRepository {
  Future<UserProfileEntity> getUserProfile();
}
