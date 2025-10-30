import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/profile/domain/entities/profile_entity.dart';
import 'package:vocabu_rex_mobile/profile/domain/entities/achievement_entity.dart';
import 'package:vocabu_rex_mobile/profile/domain/usecases/get_profile_usecase.dart';
import 'package:vocabu_rex_mobile/profile/domain/usecases/follow_user_usecase.dart';
import 'package:vocabu_rex_mobile/profile/domain/usecases/unfollow_user_usecase.dart';
import 'package:vocabu_rex_mobile/profile/domain/usecases/get_achievements_usecase.dart';

// Events
abstract class ProfileEvent {}

class GetProfileEvent extends ProfileEvent {
  GetProfileEvent();
}

class FollowUserEvent extends ProfileEvent {
  final String userId;
  FollowUserEvent(this.userId);
}

class UnfollowUserEvent extends ProfileEvent {
  final String userId;
  UnfollowUserEvent(this.userId);
}

class LoadAchievementsEvent extends ProfileEvent {
  final bool onlyUnlocked;
  LoadAchievementsEvent({this.onlyUnlocked = false});
}

// States
abstract class ProfileState {}

class ProfileInit extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;
  final List<AchievementEntity> achievements;
  
  ProfileLoaded({
    required this.profile,
    this.achievements = const [],
  });
  
  ProfileLoaded copyWith({
    ProfileEntity? profile,
    List<AchievementEntity>? achievements,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      achievements: achievements ?? this.achievements,
    );
  }
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError({required this.message});
}

class FollowActionInProgress extends ProfileState {}

class FollowActionSuccess extends ProfileState {
  final bool isFollowing;
  FollowActionSuccess({required this.isFollowing});
}

class FollowActionError extends ProfileState {
  final String message;
  FollowActionError({required this.message});
}

class AchievementsLoading extends ProfileState {}

class AchievementsLoaded extends ProfileState {
  final List<AchievementEntity> achievements;
  AchievementsLoaded({required this.achievements});
}

class AchievementsError extends ProfileState {
  final String message;
  AchievementsError({required this.message});
}

// Bloc
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUsecase getProfileUsecase;
  final FollowUserUsecase followUserUsecase;
  final UnfollowUserUsecase unfollowUserUsecase;
  final GetAchievementsUsecase getAchievementsUsecase;

  ProfileBloc({
    required this.getProfileUsecase,
    required this.followUserUsecase,
    required this.unfollowUserUsecase,
    required this.getAchievementsUsecase,
  }) : super(ProfileInit()) {
    // Get Profile
    on<GetProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        final profile = await getProfileUsecase();
        emit(ProfileLoaded(profile: profile));
      } catch (e) {
        emit(ProfileError(message: e.toString()));
      }
    });

    // Follow User
    on<FollowUserEvent>((event, emit) async {
      emit(FollowActionInProgress());
      try {
        await followUserUsecase(event.userId);
        emit(FollowActionSuccess(isFollowing: true));
        // Refresh profile to update follower count
        add(GetProfileEvent());
      } catch (e) {
        emit(FollowActionError(message: e.toString()));
      }
    });

    // Unfollow User
    on<UnfollowUserEvent>((event, emit) async {
      emit(FollowActionInProgress());
      try {
        await unfollowUserUsecase(event.userId);
        emit(FollowActionSuccess(isFollowing: false));
        // Refresh profile to update follower count
        add(GetProfileEvent());
      } catch (e) {
        emit(FollowActionError(message: e.toString()));
      }
    });

    // Load Achievements
    on<LoadAchievementsEvent>((event, emit) async {
      final currentState = state;
      if (currentState is ProfileLoaded) {
        emit(AchievementsLoading());
        try {
          final achievements = await getAchievementsUsecase(
            onlyUnlocked: event.onlyUnlocked,
          );
          emit(currentState.copyWith(achievements: achievements));
        } catch (e) {
          emit(AchievementsError(message: e.toString()));
        }
      }
    });
  }
}
