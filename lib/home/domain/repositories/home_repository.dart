import 'package:vocabu_rex_mobile/home/domain/entities/skill_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_part_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/user_progress_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/user_roadmap_entity.dart';

abstract class HomeRepository {
  Future<UserProgressEntity> getUserProgress();
  Future<SkillEntity> getSkillById(String id);
  Future<List<SkillPartEntity>> getSkillParts();
  Future<UserRoadmapEntity> getActiveUserRoadmap();
  Future<UserRoadmapEntity> generateUserRoadmap({
    String? targetLanguage,
    String? proficiencyLevel,
    List<String>? learningGoals,
    int? dailyGoalMinutes,
  });
  Future<List<UserRoadmapEntity>> getUserRoadmapHistory();
  Future<void> switchUserRoadmap(String roadmapId);
}
