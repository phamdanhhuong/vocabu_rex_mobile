import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/streak/domain/entities/get_streak_history_response_entity.dart';
import 'package:vocabu_rex_mobile/streak/domain/entities/get_streak_calendar_response_entity.dart';
import 'package:vocabu_rex_mobile/streak/domain/usecases/get_streak_history_usecase.dart';
import 'package:vocabu_rex_mobile/streak/domain/usecases/get_streak_calendar_usecase.dart';
import 'streak_event.dart';
import 'package:vocabu_rex_mobile/streak/domain/usecases/use_streak_freeze_usecase.dart';

// States
abstract class StreakState {}

class StreakInitial extends StreakState {}

class StreakLoading extends StreakState {}

class StreakLoaded extends StreakState {
  final GetStreakHistoryResponseEntity response;
  final GetStreakCalendarResponseEntity? calendarResponse;
  final bool isLoadingCalendar;
  
  StreakLoaded(
    this.response, {
    this.calendarResponse,
    this.isLoadingCalendar = false,
  });
  
  // Helper method to copy state with new calendar data
  StreakLoaded copyWith({
    GetStreakHistoryResponseEntity? response,
    GetStreakCalendarResponseEntity? calendarResponse,
    bool? isLoadingCalendar,
  }) {
    return StreakLoaded(
      response ?? this.response,
      calendarResponse: calendarResponse ?? this.calendarResponse,
      isLoadingCalendar: isLoadingCalendar ?? this.isLoadingCalendar,
    );
  }
}

class StreakCalendarLoading extends StreakState {}
class StreakCalendarLoaded extends StreakState {
  final GetStreakCalendarResponseEntity calendarResponse;
  StreakCalendarLoaded(this.calendarResponse);
}
class StreakError extends StreakState {
  final String message;
  StreakError(this.message);
}

const platform = MethodChannel('com.tlcn.vocaburex/native_service');

// Helper to check if we can use native platform channels
bool get _canUseNativeChannel => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

// Bloc
class StreakBloc extends Bloc<StreakEvent, StreakState> {
  final GetStreakHistoryUseCase getStreakHistoryUseCase;
  final UseStreakFreezeUseCase useStreakFreezeUseCase;
  final GetStreakCalendarUseCase getStreakCalendarUseCase;

  StreakBloc({
    required this.getStreakHistoryUseCase,
    required this.useStreakFreezeUseCase,
    required this.getStreakCalendarUseCase,
  }) : super(StreakInitial()) {
    on<GetStreakHistoryEvent>(_onGetStreakHistory);
    on<UseStreakFreezeEvent>(_onUseStreakFreeze);
    on<GetStreakCalendarEvent>(_onGetStreakCalendar);
  }

  Future<void> _onGetStreakHistory(
    GetStreakHistoryEvent event,
    Emitter<StreakState> emit,
  ) async {
    emit(StreakLoading());
    try {
      final response = await getStreakHistoryUseCase.call(
        limit: event.limit,
        includeCurrentStreak: event.includeCurrentStreak,
      );
      
      print('🔍 Bloc: response.currentStreak.length = ${response.currentStreak.length}');

      // Only sync to native on Android/iOS, skip on Web
      if (_canUseNativeChannel) {
        try {
          String jsonString = jsonEncode(response.toJson());
          await platform.invokeMethod('syncStreak', {"data": jsonString});
          print('✅ Synced to native platform');
        } catch (e) {
          print('⚠️ Failed to sync to native (expected on Web): $e');
        }
      } else {
        print('ℹ️ Running on Web - skipping native sync');
      }

      print('✅ Bloc: Emitting StreakLoaded with length = ${response.currentStreak.length}');
      emit(StreakLoaded(response));
    } catch (e) {
      print('❌ StreakBloc Error: $e');
      emit(StreakError(e.toString()));
    }
  }

  Future<void> _onUseStreakFreeze(
    UseStreakFreezeEvent event,
    Emitter<StreakState> emit,
  ) async {
    emit(StreakLoading());
    try {
      await useStreakFreezeUseCase.call(reason: event.reason);
      add(GetStreakHistoryEvent());
    } catch (e) {
      emit(StreakError(e.toString()));
    }
  }

  Future<void> _onGetStreakCalendar(GetStreakCalendarEvent event, Emitter<StreakState> emit) async {
    // If we already have streak data loaded, keep it and just update calendar
    if (state is StreakLoaded) {
      final currentState = state as StreakLoaded;
      emit(currentState.copyWith(isLoadingCalendar: true));
      
      try {
        final calendarResponse = await getStreakCalendarUseCase.call(
          startDate: event.startDate,
          endDate: event.endDate,
        );
        emit(currentState.copyWith(
          calendarResponse: calendarResponse,
          isLoadingCalendar: false,
        ));
      } catch (e) {
        // Keep streak data but show error for calendar
        emit(currentState.copyWith(isLoadingCalendar: false));
        print('❌ Calendar load error: $e');
      }
    } else {
      // Fallback: old behavior if streak not loaded yet
      emit(StreakCalendarLoading());
      try {
        final response = await getStreakCalendarUseCase.call(
          startDate: event.startDate,
          endDate: event.endDate,
        );
        emit(StreakCalendarLoaded(response));
      } catch (e) {
        emit(StreakError(e.toString()));
      }
    }
  }
}
