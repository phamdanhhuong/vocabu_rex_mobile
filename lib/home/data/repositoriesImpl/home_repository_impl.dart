import 'package:vocabu_rex_mobile/home/data/datasources/home_datasource.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_part_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/user_progress_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/user_roadmap_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeDatasource homeDatasource;
  HomeRepositoryImpl({required this.homeDatasource});

  @override
  Future<UserProgressEntity> getUserProgress() async {
    final model = await homeDatasource.getUserProgress();
    final result = UserProgressEntity.fromModel(model);
    return result;
  }

  @override
  Future<SkillEntity> getSkillById(String id) async {
    final model = await homeDatasource.getSkillById(id);
    final result = SkillEntity.fromModel(model);
    return result;
  }

  @override
  Future<List<SkillPartEntity>> getSkillParts() async {
    final models = await homeDatasource.getSkillParts();
    final result = models
        .map((model) => SkillPartEntity.fromModel(model))
        .toList();
    return result;
  }

  @override
  Future<UserRoadmapEntity> getActiveUserRoadmap() async {
    final model = await homeDatasource.getActiveUserRoadmap();
    return UserRoadmapEntity.fromModel(model);
  }

  @override
  Future<UserRoadmapEntity> generateUserRoadmap({
    String? targetLanguage,
    String? proficiencyLevel,
    List<String>? learningGoals,
    int? dailyGoalMinutes,
  }) async {
    final model = await homeDatasource.generateUserRoadmap(
      targetLanguage: targetLanguage,
      proficiencyLevel: proficiencyLevel,
      learningGoals: learningGoals,
      dailyGoalMinutes: dailyGoalMinutes,
    );
    return UserRoadmapEntity.fromModel(model);
  }

  @override
  Future<List<UserRoadmapEntity>> getUserRoadmapHistory() async {
    final models = await homeDatasource.getUserRoadmapHistory();
    return models.map((model) => UserRoadmapEntity.fromModel(model)).toList();
  }

  @override
  Future<void> switchUserRoadmap(String roadmapId) async {
    await homeDatasource.switchUserRoadmap(roadmapId);
  }
}
