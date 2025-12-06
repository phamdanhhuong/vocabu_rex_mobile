import 'package:vocabu_rex_mobile/home/data/datasources/home_datasource.dart';
import 'package:vocabu_rex_mobile/home/data/models/skill_model.dart';
import 'package:vocabu_rex_mobile/home/data/models/skill_part_model.dart';
import 'package:vocabu_rex_mobile/home/data/models/user_profile_model.dart';
import 'package:vocabu_rex_mobile/home/data/models/user_progress_model.dart';
import 'package:vocabu_rex_mobile/home/data/service/home_service.dart';

class HomeDatasourceImpl implements HomeDatasource {
  final HomeService homeService;
  HomeDatasourceImpl(this.homeService);

  @override
  Future<UserProfileModel> getUserProfile() async {
    final res = await homeService.getUserProfile();
    final result = UserProfileModel.fromJson(res);
    return result;
  }

  @override
  Future<UserProgressModel> getUserProgress() async {
    final res = await homeService.getUserProgress();
    if (res == null) {
      print('⚠️ No user progress found, creating default progress');
      // Return default progress for new users - start from first skill
      throw Exception('No progress found. Please initialize user progress.');
    }
    final result = UserProgressModel.fromJson(res);
    return result;
  }

  @override
  Future<SkillModel> getSkillById(String id) async {
    final res = await homeService.getSkillById(id);
    final result = SkillModel.fromJson(res);
    return result;
  }

  @override
  Future<List<SkillPartModel>> getSkillParts() async {
    final res = await homeService.getLearningParts();
    print('📦 HomeDatasource: Got ${res.length} skill parts from API');
    final result = res.map((item) {
      final model = SkillPartModel.fromJson(item);
      print('   - Part ${model.position}: ${model.name} with ${model.skills?.length ?? 0} skills');
      return model;
    }).toList();
    return result;
  }
}
