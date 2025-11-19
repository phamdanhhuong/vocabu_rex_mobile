import 'package:get_it/get_it.dart';
import '../../pronunciation/data/datasources/pronun_datasource.dart';
import '../../pronunciation/data/datasources/pronun_datasource_impl.dart';
import '../../pronunciation/data/repositories/pronun_repository_impl.dart';
import '../../pronunciation/data/services/pronunciation_service.dart';
import '../../pronunciation/domain/repositories/pronun_repository.dart';
import '../../pronunciation/domain/usecases/get_pronunciation_progress_usecase.dart';
import '../../pronunciation/ui/blocs/pronunciation_bloc.dart';

final sl = GetIt.instance;

void initPronunciationInjection() {
  // BLoC
  sl.registerFactory<PronunciationBloc>(() => PronunciationBloc(
    getPronunciationProgressUseCase: sl(),
  ));

  // Use cases
  sl.registerLazySingleton<GetPronunciationProgressUseCase>(
    () => GetPronunciationProgressUseCase(sl()),
  );

  // Repository
  sl.registerLazySingleton<PronunRepository>(
    () => PronunRepositoryImpl(dataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<PronunDatasource>(
    () => ProfileDataSourceImpl(sl()),
  );

  // Services
  sl.registerLazySingleton<PronunciationServive>(
    () => PronunciationServive(),
  );
}