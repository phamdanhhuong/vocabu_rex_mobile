import 'package:vocabu_rex_mobile/profile/data/models/achievement_model.dart';
import 'package:vocabu_rex_mobile/profile/data/service/profile_service.dart';
import 'package:vocabu_rex_mobile/profile/domain/entities/achievement_entity.dart';

class GetAchievementsUsecase {
  final ProfileService _profileService;

  GetAchievementsUsecase(this._profileService);

  Future<List<AchievementEntity>> call({bool onlyUnlocked = false}) async {
    final achievementsData = await _profileService.getAchievements(onlyUnlocked: onlyUnlocked);
    return achievementsData
        .map((json) => AchievementModel.fromJson(json).toEntity())
        .toList();
  }
}
