import 'package:vocabu_rex_mobile/home/domain/entities/user_roadmap_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/repositories/home_repository.dart';

class GenerateUserRoadmapUsecase {
  final HomeRepository homeRepository;

  GenerateUserRoadmapUsecase(this.homeRepository);

  Future<UserRoadmapEntity> call({
    String? targetLanguage,
    String? proficiencyLevel,
    List<String>? learningGoals,
    int? dailyGoalMinutes,
  }) async {
    return await homeRepository.generateUserRoadmap(
      targetLanguage: targetLanguage,
      proficiencyLevel: proficiencyLevel,
      learningGoals: learningGoals,
      dailyGoalMinutes: dailyGoalMinutes,
    );
  }
}
