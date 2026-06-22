import 'package:vocabu_rex_mobile/home/domain/repositories/home_repository.dart';

class SwitchUserRoadmapUsecase {
  final HomeRepository homeRepository;

  SwitchUserRoadmapUsecase(this.homeRepository);

  Future<void> call(String roadmapId) async {
    await homeRepository.switchUserRoadmap(roadmapId);
  }
}
