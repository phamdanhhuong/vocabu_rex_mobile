import 'package:vocabu_rex_mobile/home/domain/entities/user_roadmap_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/repositories/home_repository.dart';

class GetActiveUserRoadmapUsecase {
  final HomeRepository repository;

  GetActiveUserRoadmapUsecase(this.repository);

  Future<UserRoadmapEntity> call() {
    return repository.getActiveUserRoadmap();
  }
}
