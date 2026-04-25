import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/entities.dart';
import 'package:vocabu_rex_mobile/exercise/domain/repositories/exercise_repository.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/get_exercise_usecase.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/get_pronun_exercises_usecase.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/get_review_exercise_usecase.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/get_training_exercise_usecase.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/submit_lesson_usecase.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/submit_pronun_usecase.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/get_speak_point.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/get_image_description_score.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/get_translate_score_usecase.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/get_writing_score_usecase.dart';
import 'package:vocabu_rex_mobile/energy/ui/blocs/energy_bloc.dart';
import 'package:vocabu_rex_mobile/energy/domain/usecases/get_energy_status_usecase.dart';
import 'package:vocabu_rex_mobile/energy/domain/usecases/buy_energy_usecase.dart';
import 'package:vocabu_rex_mobile/energy/domain/repositories/energy_repository.dart';
import 'package:vocabu_rex_mobile/energy/domain/entities/energy_entity.dart';
import 'package:vocabu_rex_mobile/energy/domain/entities/buy_energy_entity.dart';
import 'package:vocabu_rex_mobile/energy/data/models/consume_energy_response_model.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/lesson_entity.dart';

/// A lightweight ExerciseBloc for Battle mode.
///
/// Extends the real [ExerciseBloc] with a dummy repository so all inherited
/// event handlers work, but none ever make API calls (exercises are never
/// loaded via network — we inject the loaded state directly).
///
/// Exercise widgets (MultipleChoiceSimple, FillBlank, etc.) can be placed under
/// `BlocProvider<ExerciseBloc>(create: (_) => BattleExerciseBloc(...))` and
/// will work identically to the normal exercise flow.
class BattleExerciseBloc extends ExerciseBloc {
  BattleExerciseBloc({
    required String exerciseId,
    required String exerciseType,
    required ExerciseMetaEntity meta,
  }) : super(
          getExerciseUseCase: GetExerciseUseCase(repository: _NoOpExerciseRepository()),
          getReviewExerciseUsecase: GetReviewExerciseUsecase(repository: _NoOpExerciseRepository()),
          getPronunExercisesUseCase: GetPronunExercisesUseCase(_NoOpExerciseRepository()),
          getTrainingExerciseUsecase: GetTrainingExerciseUsecase(repository: _NoOpExerciseRepository()),
          submitLessonUsecase: SubmitLessonUsecase(repository: _NoOpExerciseRepository()),
          submitPronunUseCase: SubmitPronunUseCase(_NoOpExerciseRepository()),
          getSpeakPoint: GetSpeakPoint(repository: _NoOpExerciseRepository()),
          getImageDescriptionScore: GetImageDescriptionScore(repository: _NoOpExerciseRepository()),
          translateScoreUseCase: GetTranslateScoreUseCase(repository: _NoOpExerciseRepository()),
          getWritingScoreUseCase: GetWritingScoreUseCase(repository: _NoOpExerciseRepository()),
          energyBloc: EnergyBloc(
            getEnergyStatusUseCase: _NoOpGetEnergyStatus(),
            buyEnergyUseCase: _NoOpBuyEnergy(),
          ),
        ) {
    // Build fake lesson + result and emit ExercisesLoaded immediately
    final exercise = ExerciseEntity(
      id: exerciseId,
      lessonId: 'battle',
      exerciseType: exerciseType,
      prompt: '',
      meta: meta,
      position: 0,
      createdAt: DateTime.now(),
      isInteractive: true,
      isContentBased: false,
    );

    final lesson = LessonEntity(
      id: 'battle',
      skillId: 'battle',
      skillLevel: 1,
      title: 'Battle',
      position: 0,
      createdAt: DateTime.now(),
      exercises: [exercise],
    );

    final result = ExerciseResultEntity(
      lessonId: 'battle',
      skillId: 'battle',
      exercises: [
        ExerciseAnswerEntity(exerciseId: exerciseId, isCorrect: false, incorrectCount: 0),
      ],
    );

    // Force initial state to loaded
    // ignore: invalid_use_of_visible_for_testing_member
    emit(ExercisesLoaded(lesson: lesson, result: result));
  }
}

// ─── No-op repository (all methods throw if called, but they never will) ───

class _NoOpExerciseRepository implements ExerciseRepository {
  @override
  Future<LessonEntity> getExercisesByLessonId(String lessonId) => throw UnimplementedError('Battle mode');
  @override
  Future<LessonEntity> getReviewExercises() => throw UnimplementedError('Battle mode');
  @override
  Future<LessonEntity> getPronunExercises() => throw UnimplementedError('Battle mode');
  @override
  Future<LessonEntity> getTrainingExercises({String? trainingType}) => throw UnimplementedError('Battle mode');
  @override
  Future<SubmitResponseEntity> submit(ExerciseResultEntity result) => throw UnimplementedError('Battle mode');
  @override
  Future<SubmitResponseEntity> submitPronun(ExerciseResultEntity result) => throw UnimplementedError('Battle mode');
  @override
  Future<PronunciationAnalysisEntity> getSpeakPoint(String path, String referenceText) => throw UnimplementedError('Battle mode');
  @override
  Future<ImageDescriptionScoreEntity> imgDescriptionScore(String content, String expectResult) => throw UnimplementedError('Battle mode');
  @override
  Future<TranslateScoreEntity> translateScore(String userAnswer, String sourceText, String correctAnswer) => throw UnimplementedError('Battle mode');
  @override
  Future<WritingScoreEntity> writingScore(String userAnswer, WritingPromptMetaEntity meta) => throw UnimplementedError('Battle mode');
}

class _NoOpGetEnergyStatus extends GetEnergyStatusUseCase {
  _NoOpGetEnergyStatus() : super(repository: _NoOpEnergyRepo());
}

class _NoOpBuyEnergy extends BuyEnergyUseCase {
  _NoOpBuyEnergy() : super(repository: _NoOpEnergyRepo());
}

class _NoOpEnergyRepo implements EnergyRepository {
  @override
  Future<EnergyEntity> getEnergyStatus({bool? includeTransactionHistory, int? historyLimit}) => throw UnimplementedError();
  @override
  Future<BuyEnergyEntity> buyEnergy({required int energyAmount, required String paymentMethod}) => throw UnimplementedError();
  @override
  Future<ConsumeEnergyResponseModel> consumeEnergy({int amount = 1, String? referenceId, String? idempotencyKey, String? reason, String? activityType, Map<String, dynamic>? metadata, String? source}) => throw UnimplementedError();
}
