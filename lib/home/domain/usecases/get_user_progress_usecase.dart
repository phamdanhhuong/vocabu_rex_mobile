import 'package:vocabu_rex_mobile/home/domain/entities/user_progress_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/repositories/home_repository.dart';

class GetUserProgressUsecase {
  final HomeRepository homeRepository;
  GetUserProgressUsecase({required this.homeRepository});
  Future<UserProgressEntity> call() async {
    return homeRepository.getUserProgress();
  }
}
