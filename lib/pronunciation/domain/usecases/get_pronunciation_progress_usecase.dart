import '../entities/entities.dart';
import '../repositories/pronun_repository.dart';

class GetPronunciationProgressUseCase {
  final PronunRepository repository;

  GetPronunciationProgressUseCase(this.repository);

  Future<PronunciationProgress?> call() async {
    return await repository.getPronunciationProgress();
  }
}
