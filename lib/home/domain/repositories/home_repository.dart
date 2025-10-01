import 'package:vocabu_rex_mobile/home/domain/entities/skill_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/user_profile_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/user_progress_entity.dart';

abstract class HomeRepository {
  Future<UserProfileEntity> getUserProfile();
  Future<UserProgressEntity> getUserProgress();
  Future<SkillEntity> getSkillById(String id);
}
