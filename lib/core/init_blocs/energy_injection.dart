import 'package:get_it/get_it.dart';
import 'package:vocabu_rex_mobile/energy/data/datasources/energy_datasource.dart';
import 'package:vocabu_rex_mobile/energy/data/datasources/energy_datasource_impl.dart';
import 'package:vocabu_rex_mobile/energy/data/repositories/energy_repository_impl.dart';
import 'package:vocabu_rex_mobile/energy/data/services/energy_service.dart';
import 'package:vocabu_rex_mobile/energy/domain/repositories/energy_repository.dart';
import 'package:vocabu_rex_mobile/energy/domain/usecases/get_energy_status_usecase.dart';
import 'package:vocabu_rex_mobile/energy/domain/usecases/buy_energy_usecase.dart';
import 'package:vocabu_rex_mobile/energy/ui/blocs/energy_bloc.dart';

final GetIt sl = GetIt.instance;

void initEnergy() {
  // Service
  sl.registerLazySingleton<EnergyService>(() => EnergyService());

  // DataSource
  sl.registerLazySingleton<EnergyDatasource>(() => EnergyDatasourceImpl(sl()));

  // Repository
  sl.registerLazySingleton<EnergyRepository>(
    () => EnergyRepositoryImpl(datasource: sl()),
  );

  // UseCase
  sl.registerLazySingleton<GetEnergyStatusUseCase>(
    () => GetEnergyStatusUseCase(repository: sl()),
  );

  sl.registerLazySingleton<BuyEnergyUseCase>(
    () => BuyEnergyUseCase(repository: sl()),
  );

  // Bloc
  // EnergyBloc is used across the app and sometimes accessed via sl<EnergyBloc>()
  // (for example from ExerciseBloc) — register it as a singleton so all callers
  // get the same instance that is provided to the widget tree in main.dart.
  sl.registerLazySingleton<EnergyBloc>(
    () => EnergyBloc(getEnergyStatusUseCase: sl(), buyEnergyUseCase: sl()),
  );
}
