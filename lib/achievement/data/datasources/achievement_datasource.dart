import 'package:vocabu_rex_mobile/achievement/data/models/achievement_model.dart';

abstract class AchievementDataSource {
  Future<List<AchievementModel>> getAchievements({bool onlyUnlocked = false});
  
  Future<Map<String, List<AchievementModel>>> getAchievementsSummary();
}
