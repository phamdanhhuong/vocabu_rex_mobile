import 'package:vocabu_rex_mobile/achievement/domain/entities/achievement_entity.dart';
import 'package:vocabu_rex_mobile/achievement/domain/repositories/achievement_repository.dart';

class GetAchievementsByCategoryUsecase {
  final AchievementRepository _repository;

  GetAchievementsByCategoryUsecase(this._repository);

  Future<Map<String, List<AchievementEntity>>> call({
    bool onlyUnlocked = false,
  }) async {
    return await _repository.getAchievementsByCategory(
      onlyUnlocked: onlyUnlocked,
    );
  }
}
