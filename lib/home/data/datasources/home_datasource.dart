import 'package:vocabu_rex_mobile/home/data/models/skill_model.dart';
import 'package:vocabu_rex_mobile/home/data/models/skill_part_model.dart';
import 'package:vocabu_rex_mobile/home/data/models/user_profile_model.dart';
import 'package:vocabu_rex_mobile/home/data/models/user_progress_model.dart';

abstract class HomeDatasource {
  Future<UserProfileModel> getUserProfile();
  Future<UserProgressModel> getUserProgress();
  Future<SkillModel> getSkillById(String id);
  Future<List<SkillPartModel>> getSkillParts();
}
