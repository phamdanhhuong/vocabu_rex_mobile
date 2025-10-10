import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/profile/domain/entities/profile_entity.dart';
import 'package:vocabu_rex_mobile/profile/domain/usecases/get_profile_usecase.dart';

// Event
abstract class ProfileEvent {}

class GetProfileEvent extends ProfileEvent {
  GetProfileEvent();
}

// State
abstract class ProfileState {}

class ProfileInit extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;
  ProfileLoaded({required this.profile});
}
class ProfileError extends ProfileState {
  final String message;
  ProfileError({required this.message});
}

// Bloc
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUsecase getProfileUsecase;

  ProfileBloc({required this.getProfileUsecase}) : super(ProfileInit()) {
    on<GetProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        final profile = await getProfileUsecase();
        emit(ProfileLoaded(profile: profile));
      } catch (e) {
        emit(ProfileError(message: e.toString()));
      }
    });
  }
}
