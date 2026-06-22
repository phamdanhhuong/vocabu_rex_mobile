import 'package:vocabu_rex_mobile/home/domain/entities/user_roadmap_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/repositories/home_repository.dart';

class GetUserRoadmapHistoryUsecase {
  final HomeRepository homeRepository;

  GetUserRoadmapHistoryUsecase(this.homeRepository);

  Future<List<UserRoadmapEntity>> call() async {
    return await homeRepository.getUserRoadmapHistory();
  }
}
