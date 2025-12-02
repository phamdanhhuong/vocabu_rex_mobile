import 'package:vocabu_rex_mobile/achievement/domain/entities/achievement_entity.dart';
import 'package:vocabu_rex_mobile/achievement/domain/repositories/achievement_repository.dart';

class GetRecentAchievementsUsecase {
  final AchievementRepository _repository;

  GetRecentAchievementsUsecase(this._repository);

  Future<List<AchievementEntity>> call({int limit = 3}) async {
    return await _repository.getRecentAchievements(limit: limit);
  }
}
