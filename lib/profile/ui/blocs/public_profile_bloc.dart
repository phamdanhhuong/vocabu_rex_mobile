import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/profile/domain/entities/public_profile_entity.dart';
import 'package:vocabu_rex_mobile/profile/domain/usecases/get_public_profile_usecase.dart';
import 'package:vocabu_rex_mobile/profile/domain/usecases/follow_user_usecase.dart';
import 'package:vocabu_rex_mobile/profile/domain/usecases/unfollow_user_usecase.dart';
import 'package:vocabu_rex_mobile/profile/domain/usecases/report_user_usecase.dart';
import 'package:vocabu_rex_mobile/profile/domain/usecases/block_user_usecase.dart';

// Events
abstract class PublicProfileEvent {}

class GetPublicProfileEvent extends PublicProfileEvent {
  final String userId;
  GetPublicProfileEvent(this.userId);
}

class FollowPublicUserEvent extends PublicProfileEvent {
  final String userId;
  FollowPublicUserEvent(this.userId);
}

class UnfollowPublicUserEvent extends PublicProfileEvent {
  final String userId;
  UnfollowPublicUserEvent(this.userId);
}

class ReportPublicUserEvent extends PublicProfileEvent {
  final String userId;
  final String reason;
  final String? description;
  
  ReportPublicUserEvent({
    required this.userId,
    required this.reason,
    this.description,
  });
}

class BlockPublicUserEvent extends PublicProfileEvent {
  final String userId;
  BlockPublicUserEvent(this.userId);
}

// States
abstract class PublicProfileState {}

class PublicProfileInitial extends PublicProfileState {}

class PublicProfileLoading extends PublicProfileState {}

class PublicProfileLoaded extends PublicProfileState {
  final PublicProfileEntity profile;
  
  PublicProfileLoaded({required this.profile});
}

class PublicProfileError extends PublicProfileState {
  final String message;
  PublicProfileError({required this.message});
}

class PublicProfileActionInProgress extends PublicProfileState {}

class PublicProfileActionSuccess extends PublicProfileState {
  final String message;
  PublicProfileActionSuccess({required this.message});
}

class PublicProfileActionError extends PublicProfileState {
  final String message;
  PublicProfileActionError({required this.message});
}

// Bloc
class PublicProfileBloc extends Bloc<PublicProfileEvent, PublicProfileState> {
  final GetPublicProfileUsecase getPublicProfileUsecase;
  final FollowUserUsecase followUserUsecase;
  final UnfollowUserUsecase unfollowUserUsecase;
  final ReportUserUsecase reportUserUsecase;
  final BlockUserUsecase blockUserUsecase;

  PublicProfileBloc({
    required this.getPublicProfileUsecase,
    required this.followUserUsecase,
    required this.unfollowUserUsecase,
    required this.reportUserUsecase,
    required this.blockUserUsecase,
  }) : super(PublicProfileInitial()) {
    // Get Public Profile
    on<GetPublicProfileEvent>((event, emit) async {
      emit(PublicProfileLoading());
      try {
        final profile = await getPublicProfileUsecase(event.userId);
        emit(PublicProfileLoaded(profile: profile));
      } catch (e) {
        emit(PublicProfileError(message: e.toString()));
      }
    });

    // Follow User
    on<FollowPublicUserEvent>((event, emit) async {
      final currentState = state;
      emit(PublicProfileActionInProgress());
      try {
        await followUserUsecase(event.userId);
        emit(PublicProfileActionSuccess(message: 'Đã theo dõi'));
        // Refresh profile
        add(GetPublicProfileEvent(event.userId));
      } catch (e) {
        emit(PublicProfileActionError(message: e.toString()));
        if (currentState is PublicProfileLoaded) {
          emit(currentState);
        }
      }
    });

    // Unfollow User
    on<UnfollowPublicUserEvent>((event, emit) async {
      final currentState = state;
      emit(PublicProfileActionInProgress());
      try {
        await unfollowUserUsecase(event.userId);
        emit(PublicProfileActionSuccess(message: 'Đã bỏ theo dõi'));
        // Refresh profile
        add(GetPublicProfileEvent(event.userId));
      } catch (e) {
        emit(PublicProfileActionError(message: e.toString()));
        if (currentState is PublicProfileLoaded) {
          emit(currentState);
        }
      }
    });

    // Report User
    on<ReportPublicUserEvent>((event, emit) async {
      final currentState = state;
      emit(PublicProfileActionInProgress());
      try {
        await reportUserUsecase(
          userId: event.userId,
          reason: event.reason,
          description: event.description,
        );
        emit(PublicProfileActionSuccess(message: 'Đã gửi báo cáo'));
        if (currentState is PublicProfileLoaded) {
          emit(currentState);
        }
      } catch (e) {
        emit(PublicProfileActionError(message: e.toString()));
        if (currentState is PublicProfileLoaded) {
          emit(currentState);
        }
      }
    });

    // Block User
    on<BlockPublicUserEvent>((event, emit) async {
      emit(PublicProfileActionInProgress());
      try {
        await blockUserUsecase(event.userId);
        emit(PublicProfileActionSuccess(message: 'Đã chặn người dùng'));
      } catch (e) {
        emit(PublicProfileActionError(message: e.toString()));
      }
    });
  }
}
