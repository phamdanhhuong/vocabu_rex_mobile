import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/user_profile_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/user_progress_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/usecases/get_skill_by_id_usecase.dart';
import 'package:vocabu_rex_mobile/home/domain/usecases/get_user_profile_usecase.dart';
import 'package:vocabu_rex_mobile/home/domain/usecases/get_user_progress_usecase.dart';

//Event
abstract class HomeEvent {}

class GetUserProfileEvent extends HomeEvent {}

class GetSkillEvent extends HomeEvent {
  String id;
  GetSkillEvent({required this.id});
}

//State
abstract class HomeState {}

class HomeInit extends HomeState {}

class HomeUnauthen extends HomeState {}

class HomeLoading extends HomeState {}

class HomeSuccess extends HomeState {
  final UserProfileEntity userProfileEntity;
  final UserProgressEntity userProgressEntity;
  final SkillEntity? skillEntity;

  HomeSuccess({
    required this.userProfileEntity,
    required this.userProgressEntity,
    this.skillEntity,
  });

  HomeSuccess copyWith({
    UserProfileEntity? userProfileEntity,
    UserProgressEntity? userProgressEntity,
    SkillEntity? skillEntity,
  }) {
    return HomeSuccess(
      userProfileEntity: userProfileEntity ?? this.userProfileEntity,
      userProgressEntity: userProgressEntity ?? this.userProgressEntity,
      skillEntity: skillEntity ?? this.skillEntity,
    );
  }
}

//Bloc
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetUserProfileUsecase getUserProfileUsecase;
  final GetUserProgressUsecase getUserProgressUsecase;
  final GetSkillByIdUsecase getSkillByIdUsecase;

  HomeBloc({
    required this.getUserProfileUsecase,
    required this.getUserProgressUsecase,
    required this.getSkillByIdUsecase,
  }) : super(HomeInit()) {
    on<GetUserProfileEvent>((event, emit) async {
      emit(HomeLoading());
      try {
        final profile = await getUserProfileUsecase();
        final progress = await getUserProgressUsecase();
        emit(
          HomeSuccess(userProfileEntity: profile, userProgressEntity: progress),
        );
      } catch (e) {
        print(e);
        emit(HomeUnauthen());
      }
    });

    on<GetSkillEvent>((event, emit) async {
      if (state is HomeSuccess) {
        final currentState = state as HomeSuccess;
        emit(HomeLoading());

        try {
          final skill = await getSkillByIdUsecase(event.id);
          emit(currentState.copyWith(skillEntity: skill));
        } catch (e) {
          print(e);
          emit(HomeUnauthen());
        }
      } else {
        // Nếu chưa có dữ liệu user, cần fetch trước
        emit(HomeLoading());
        try {
          final profile = await getUserProfileUsecase();
          final progress = await getUserProgressUsecase();
          final skill = await getSkillByIdUsecase(event.id);

          emit(
            HomeSuccess(
              userProfileEntity: profile,
              userProgressEntity: progress,
              skillEntity: skill,
            ),
          );
        } catch (e) {
          print(e);
          emit(HomeUnauthen());
        }
      }
    });
  }
}
