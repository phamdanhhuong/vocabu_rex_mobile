import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/achievement/domain/entities/achievement_entity.dart';
import 'package:vocabu_rex_mobile/achievement/domain/usecases/get_achievements_usecase.dart';
import 'package:vocabu_rex_mobile/achievement/domain/usecases/get_achievements_by_category_usecase.dart';
import 'package:vocabu_rex_mobile/achievement/domain/usecases/get_recent_achievements_usecase.dart';
import 'package:vocabu_rex_mobile/achievement/domain/usecases/get_achievements_summary_usecase.dart';

// Events
abstract class AchievementEvent {}

class LoadAllAchievementsEvent extends AchievementEvent {
  final bool onlyUnlocked;

  LoadAllAchievementsEvent({this.onlyUnlocked = false});
}

class LoadAchievementsByCategoryEvent extends AchievementEvent {
  final bool onlyUnlocked;

  LoadAchievementsByCategoryEvent({this.onlyUnlocked = false});
}

class LoadAchievementsSummaryEvent extends AchievementEvent {}

class LoadRecentAchievementsEvent extends AchievementEvent {
  final int limit;

  LoadRecentAchievementsEvent({this.limit = 3});
}

class FilterAchievementsEvent extends AchievementEvent {
  final bool showOnlyUnlocked;

  FilterAchievementsEvent({required this.showOnlyUnlocked});
}

// States
abstract class AchievementState {}

class AchievementInitial extends AchievementState {}

class AchievementLoading extends AchievementState {}

class AchievementLoaded extends AchievementState {
  final List<AchievementEntity> achievements;
  final Map<String, List<AchievementEntity>>? achievementsByCategory;
  final List<AchievementEntity>? recentAchievements;
  final List<AchievementEntity>? personalAchievements;
  final List<AchievementEntity>? awardsAchievements;
  final bool showOnlyUnlocked;

  AchievementLoaded({
    required this.achievements,
    this.achievementsByCategory,
    this.recentAchievements,
    this.personalAchievements,
    this.awardsAchievements,
    this.showOnlyUnlocked = false,
  });

  // Helper getters
  int get totalCount => achievements.length;
  
  int get unlockedCount => 
      achievements.where((a) => a.isUnlocked).length;
  
  int get inProgressCount => 
      achievements.where((a) => a.isInProgress).length;
  
  int get lockedCount => 
      achievements.where((a) => !a.isUnlocked && a.progress == 0).length;

  // Calculate total XP earned from unlocked achievements
  int get totalXpEarned => achievements
      .where((a) => a.isUnlocked)
      .fold(0, (sum, a) => sum + a.achievement.rewardXp);

  // Calculate total Gems earned from unlocked achievements
  int get totalGemsEarned => achievements
      .where((a) => a.isUnlocked)
      .fold(0, (sum, a) => sum + a.achievement.rewardGems);

  AchievementLoaded copyWith({
    List<AchievementEntity>? achievements,
    Map<String, List<AchievementEntity>>? achievementsByCategory,
    List<AchievementEntity>? recentAchievements,
    List<AchievementEntity>? personalAchievements,
    List<AchievementEntity>? awardsAchievements,
    bool? showOnlyUnlocked,
  }) {
    return AchievementLoaded(
      achievements: achievements ?? this.achievements,
      achievementsByCategory: achievementsByCategory ?? this.achievementsByCategory,
      recentAchievements: recentAchievements ?? this.recentAchievements,
      personalAchievements: personalAchievements ?? this.personalAchievements,
      awardsAchievements: awardsAchievements ?? this.awardsAchievements,
      showOnlyUnlocked: showOnlyUnlocked ?? this.showOnlyUnlocked,
    );
  }
}

class AchievementError extends AchievementState {
  final String message;

  AchievementError({required this.message});
}

// BLoC
class AchievementBloc extends Bloc<AchievementEvent, AchievementState> {
  final GetAchievementsUsecase getAchievementsUsecase;
  final GetAchievementsByCategoryUsecase getAchievementsByCategoryUsecase;
  final GetRecentAchievementsUsecase getRecentAchievementsUsecase;
  final GetAchievementsSummaryUsecase getAchievementsSummaryUsecase;

  AchievementBloc({
    required this.getAchievementsUsecase,
    required this.getAchievementsByCategoryUsecase,
    required this.getRecentAchievementsUsecase,
    required this.getAchievementsSummaryUsecase,
  }) : super(AchievementInitial()) {
    
    // Load all achievements
    on<LoadAllAchievementsEvent>((event, emit) async {
      emit(AchievementLoading());
      try {
        final achievements = await getAchievementsUsecase(
          onlyUnlocked: event.onlyUnlocked,
        );
        emit(AchievementLoaded(
          achievements: achievements,
          showOnlyUnlocked: event.onlyUnlocked,
        ));
      } catch (e) {
        emit(AchievementError(message: e.toString()));
      }
    });

    // Load achievements summary (personal + highest tier for each category)
    on<LoadAchievementsSummaryEvent>((event, emit) async {
      emit(AchievementLoading());
      try {
        final summary = await getAchievementsSummaryUsecase();
        final personalAchievements = summary['personal'] ?? [];
        final awardsAchievements = summary['awards'] ?? [];
        
        emit(AchievementLoaded(
          achievements: [...personalAchievements, ...awardsAchievements],
          personalAchievements: personalAchievements,
          awardsAchievements: awardsAchievements,
        ));
      } catch (e) {
        emit(AchievementError(message: e.toString()));
      }
    });

    // Load achievements grouped by category
    on<LoadAchievementsByCategoryEvent>((event, emit) async {
      emit(AchievementLoading());
      try {
        final achievements = await getAchievementsUsecase(
          onlyUnlocked: event.onlyUnlocked,
        );
        final achievementsByCategory = await getAchievementsByCategoryUsecase(
          onlyUnlocked: event.onlyUnlocked,
        );
        final recentAchievements = await getRecentAchievementsUsecase(limit: 3);
        
        emit(AchievementLoaded(
          achievements: achievements,
          achievementsByCategory: achievementsByCategory,
          recentAchievements: recentAchievements,
          showOnlyUnlocked: event.onlyUnlocked,
        ));
      } catch (e) {
        emit(AchievementError(message: e.toString()));
      }
    });

    // Load recent achievements
    on<LoadRecentAchievementsEvent>((event, emit) async {
      final currentState = state;
      if (currentState is AchievementLoaded) {
        try {
          final recentAchievements = await getRecentAchievementsUsecase(
            limit: event.limit,
          );
          emit(currentState.copyWith(recentAchievements: recentAchievements));
        } catch (e) {
          emit(AchievementError(message: e.toString()));
        }
      }
    });

    // Filter achievements
    on<FilterAchievementsEvent>((event, emit) async {
      emit(AchievementLoading());
      try {
        final achievements = await getAchievementsUsecase(
          onlyUnlocked: event.showOnlyUnlocked,
        );
        final achievementsByCategory = await getAchievementsByCategoryUsecase(
          onlyUnlocked: event.showOnlyUnlocked,
        );
        
        emit(AchievementLoaded(
          achievements: achievements,
          achievementsByCategory: achievementsByCategory,
          showOnlyUnlocked: event.showOnlyUnlocked,
        ));
      } catch (e) {
        emit(AchievementError(message: e.toString()));
      }
    });
  }
}
