import 'package:vocabu_rex_mobile/achievement/domain/entities/achievement_entity.dart';
import 'package:vocabu_rex_mobile/achievement/domain/repositories/achievement_repository.dart';

class GetAchievementsSummaryUsecase {
  final AchievementRepository repository;

  GetAchievementsSummaryUsecase(this.repository);

  Future<Map<String, List<AchievementEntity>>> call() async {
    return await repository.getAchievementsSummary();
  }
}
