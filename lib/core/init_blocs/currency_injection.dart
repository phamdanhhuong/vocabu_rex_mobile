import 'package:get_it/get_it.dart';
import 'package:vocabu_rex_mobile/currency/data/datasources/currency_datasource.dart';
import 'package:vocabu_rex_mobile/currency/data/datasources/currency_datasource_impl.dart';
import 'package:vocabu_rex_mobile/currency/data/datasources/payment_datasource.dart';
import 'package:vocabu_rex_mobile/currency/data/datasources/payment_datasource_impl.dart';
import 'package:vocabu_rex_mobile/currency/data/repositories/currency_repository_impl.dart';
import 'package:vocabu_rex_mobile/currency/data/repositories/payment_repository_impl.dart';
import 'package:vocabu_rex_mobile/currency/data/services/currency_service.dart';
import 'package:vocabu_rex_mobile/currency/data/services/payment_service.dart';
import 'package:vocabu_rex_mobile/currency/domain/repositories/payment_repository.dart';
import 'package:vocabu_rex_mobile/currency/domain/usecases/get_currency_balance_usecase.dart';
import 'package:vocabu_rex_mobile/currency/domain/usecases/payment_usecase.dart';
import 'package:vocabu_rex_mobile/currency/ui/blocs/currency_bloc.dart';
import 'package:vocabu_rex_mobile/currency/ui/blocs/payment_bloc.dart';

final GetIt sl = GetIt.instance;

void initCurrency() {
  // Service
  sl.registerLazySingleton<CurrencyService>(() => CurrencyService());
  sl.registerLazySingleton<PaymentService>(() => PaymentService());

  // DataSource
  sl.registerLazySingleton<CurrencyDataSource>(
    () => CurrencyDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<PaymentDataSource>(
    () => PaymentDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<CurrencyRepository>(
    () => CurrencyRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(remoteDataSource: sl()),
  );

  // UseCase
  sl.registerLazySingleton<GetCurrencyBalanceUseCase>(
    () => GetCurrencyBalanceUseCase(repository: sl()),
  );
  sl.registerLazySingleton<GetPaymentPackagesUseCase>(
    () => GetPaymentPackagesUseCase(repository: sl()),
  );
  sl.registerLazySingleton<CreatePaymentUseCase>(
    () => CreatePaymentUseCase(repository: sl()),
  );

  // Bloc
  sl.registerFactory<CurrencyBloc>(
    () => CurrencyBloc(getCurrencyBalanceUseCase: sl()),
  );
  sl.registerFactory<PaymentBloc>(
    () => PaymentBloc(
      getPaymentPackagesUseCase: sl(),
      createPaymentUseCase: sl(),
    ),
  );
}
