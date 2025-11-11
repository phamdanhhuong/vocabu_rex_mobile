import 'package:get_it/get_it.dart';
import 'package:vocabu_rex_mobile/currency/data/datasources/currency_datasource.dart';
import 'package:vocabu_rex_mobile/currency/data/datasources/currency_datasource_impl.dart';
import 'package:vocabu_rex_mobile/currency/data/repositories/currency_repository_impl.dart';
import 'package:vocabu_rex_mobile/currency/data/services/currency_service.dart';
import 'package:vocabu_rex_mobile/currency/domain/usecases/get_currency_balance_usecase.dart';
import 'package:vocabu_rex_mobile/currency/ui/blocs/currency_bloc.dart';

final GetIt sl = GetIt.instance;

void initCurrency() {
  // Service
  sl.registerLazySingleton<CurrencyService>(() => CurrencyService());

  // DataSource
  sl.registerLazySingleton<CurrencyDataSource>(
    () => CurrencyDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<CurrencyRepository>(
    () => CurrencyRepositoryImpl(remoteDataSource: sl()),
  );

  // UseCase
  sl.registerLazySingleton<GetCurrencyBalanceUseCase>(
    () => GetCurrencyBalanceUseCase(repository: sl()),
  );

  // Bloc
  sl.registerFactory<CurrencyBloc>(
    () => CurrencyBloc(getCurrencyBalanceUseCase: sl()),
  );
}
