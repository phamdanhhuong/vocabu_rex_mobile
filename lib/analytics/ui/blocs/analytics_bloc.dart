import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/analytics/data/models/analytics_model.dart';
import 'package:vocabu_rex_mobile/analytics/data/service/analytics_service.dart';

// Events
abstract class AnalyticsEvent {}

class LoadAnalyticsDashboard extends AnalyticsEvent {}

// States
abstract class AnalyticsState {}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsLoaded extends AnalyticsState {
  final AnalyticsDashboardModel dashboard;
  AnalyticsLoaded({required this.dashboard});
}

class AnalyticsError extends AnalyticsState {
  final String message;
  AnalyticsError({required this.message});
}

// Bloc
class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsService analyticsService;

  AnalyticsBloc({required this.analyticsService}) : super(AnalyticsInitial()) {
    on<LoadAnalyticsDashboard>((event, emit) async {
      emit(AnalyticsLoading());
      try {
        final data = await analyticsService.getDashboard();
        final dashboard = AnalyticsDashboardModel.fromJson(data);
        emit(AnalyticsLoaded(dashboard: dashboard));
      } catch (e) {
        emit(AnalyticsError(message: e.toString()));
      }
    });
  }
}
