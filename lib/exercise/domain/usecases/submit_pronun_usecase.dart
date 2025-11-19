import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_result_entity.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/submit_response_entity.dart';
import 'package:vocabu_rex_mobile/exercise/domain/repositories/exercise_repository.dart';

class SubmitPronunUseCase {
  final ExerciseRepository repository;

  SubmitPronunUseCase(this.repository);

  Future<SubmitResponseEntity> call(ExerciseResultEntity result) async {
    return await repository.submitPronun(result);
  }
}
