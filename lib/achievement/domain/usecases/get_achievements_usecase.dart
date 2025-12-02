import 'package:vocabu_rex_mobile/achievement/domain/entities/achievement_entity.dart';
import 'package:vocabu_rex_mobile/achievement/domain/repositories/achievement_repository.dart';

class GetAchievementsUsecase {
  final AchievementRepository _repository;

  GetAchievementsUsecase(this._repository);

  Future<List<AchievementEntity>> call({bool onlyUnlocked = false}) async {
    return await _repository.getAchievements(onlyUnlocked: onlyUnlocked);
  }
}
