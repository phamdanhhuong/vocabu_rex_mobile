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
    final result = res.map((item) => SkillPartModel.fromJson(item)).toList();
    return result;
  }
}
