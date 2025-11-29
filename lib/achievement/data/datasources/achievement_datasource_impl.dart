import 'package:vocabu_rex_mobile/achievement/data/datasources/achievement_datasource.dart';
import 'package:vocabu_rex_mobile/achievement/data/models/achievement_model.dart';
import 'package:vocabu_rex_mobile/achievement/data/service/achievement_service.dart';

class AchievementDataSourceImpl implements AchievementDataSource {
  final AchievementService achievementService;

  AchievementDataSourceImpl(this.achievementService);

  @override
  Future<List<AchievementModel>> getAchievements({
    bool onlyUnlocked = false,
  }) async {
    final response = await achievementService.getAchievements(
      onlyUnlocked: onlyUnlocked,
    );
    return response.map((json) => AchievementModel.fromJson(json)).toList();
  }

  @override
  Future<Map<String, List<AchievementModel>>> getAchievementsSummary() async {
    final response = await achievementService.getAchievementsSummary();
    
    final personalList = (response['personal'] as List)
        .map((json) => AchievementModel.fromJson(json))
        .toList();
    
    final awardsList = (response['awards'] as List)
        .map((json) => AchievementModel.fromJson(json))
        .toList();
    
    return {
      'personal': personalList,
      'awards': awardsList,
    };
  }
}
