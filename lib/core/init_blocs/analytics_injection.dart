import 'package:get_it/get_it.dart';
import 'package:vocabu_rex_mobile/analytics/data/service/analytics_service.dart';
import 'package:vocabu_rex_mobile/analytics/ui/blocs/analytics_bloc.dart';

final GetIt sl = GetIt.instance;

void initAnalytics() {
  // Service
  sl.registerLazySingleton<AnalyticsService>(() => AnalyticsService());

  // Bloc
  sl.registerFactory<AnalyticsBloc>(
    () => AnalyticsBloc(analyticsService: sl()),
  );
}
