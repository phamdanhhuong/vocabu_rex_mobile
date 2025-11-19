import 'package:get_it/get_it.dart';
import 'package:vocabu_rex_mobile/exercise/data/datasources/exercise_datasource.dart';
import 'package:vocabu_rex_mobile/exercise/data/datasources/exercise_datasource_impl.dart';
import 'package:vocabu_rex_mobile/exercise/data/repositoriesImpl/exercise_repository_impl.dart';
import 'package:vocabu_rex_mobile/exercise/data/services/exercise_service.dart';
import 'package:vocabu_rex_mobile/exercise/domain/repositories/exercise_repository.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/get_exercise_usecase.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/get_pronun_exercises_usecase.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/submit_lesson_usecase.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/get_image_description_score.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/get_review_exercise_usecase.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/get_speak_point.dart';
import 'package:vocabu_rex_mobile/energy/domain/usecases/consume_energy_usecase.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/submit_pronun_usecase.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/energy/ui/blocs/energy_bloc.dart';

final GetIt sl = GetIt.instance;

void initExercise() {
  // Service
  sl.registerLazySingleton<ExerciseService>(() => ExerciseService());

  // DataSource
  sl.registerLazySingleton<ExerciseDataSource>(
    () => ExerciseDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<ExerciseRepository>(
    () => ExcerciseRepositoryImpl(exerciseDataSource: sl()),
  );

  // UseCase
  sl.registerLazySingleton<GetExerciseUseCase>(
    () => GetExerciseUseCase(repository: sl()),
  );

  sl.registerLazySingleton<GetPronunExercisesUseCase>(
    () => GetPronunExercisesUseCase(sl()),
  );

  sl.registerLazySingleton<GetReviewExerciseUsecase>(
    () => GetReviewExerciseUsecase(repository: sl()),
  );

  sl.registerLazySingleton<SubmitPronunUseCase>(
    () => SubmitPronunUseCase(sl()),
  );

  sl.registerLazySingleton<SubmitLessonUsecase>(
    () => SubmitLessonUsecase(repository: sl()),
  );

  sl.registerLazySingleton<GetSpeakPoint>(
    () => GetSpeakPoint(repository: sl()),
  );

  sl.registerLazySingleton<GetImageDescriptionScore>(
    () => GetImageDescriptionScore(repository: sl()),
  );

  // Consume energy usecase (for per-exercise deductions)
  sl.registerLazySingleton<ConsumeEnergyUseCase>(
    () => ConsumeEnergyUseCase(repository: sl()),
  );

  // Bloc
  sl.registerFactory<ExerciseBloc>(
    () => ExerciseBloc(
      getExerciseUseCase: sl(),
      getReviewExerciseUsecase: sl(),
      getPronunExercisesUseCase: sl(),
      submitPronunUseCase: sl(),
      submitLessonUsecase: sl(),
      getSpeakPoint: sl(),
      getImageDescriptionScore: sl(),
      consumeEnergyUseCase: sl(),
      energyBloc: sl<EnergyBloc>(),
    ),
  );
}
