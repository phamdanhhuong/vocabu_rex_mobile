//Event
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/user_profile_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/usecases/get_user_profile_usecase.dart';

abstract class HomeEvent {}

class GetUserProfileEvent extends HomeEvent {}

//State
abstract class HomeState {}

class HomeInit extends HomeState {}

class HomeUnauthen extends HomeState {}

class HomeLoading extends HomeState {}

class HomeSuccess extends HomeState {
  final UserProfileEntity userProfileEntity;
  HomeSuccess({required this.userProfileEntity});
}

//Bloc
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetUserProfileUsecase getUserProfileUsecase;

  HomeBloc({required this.getUserProfileUsecase}) : super(HomeInit()) {
    on<GetUserProfileEvent>((event, emit) async {
      emit(HomeLoading());
      try {
        final profile = await getUserProfileUsecase();
        emit(HomeSuccess(userProfileEntity: profile));
      } catch (e) {
        print(e);
        emit(HomeUnauthen());
      }
    });
  }
}
