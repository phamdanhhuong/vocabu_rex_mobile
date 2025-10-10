import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/user_progress_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/usecases/get_skill_by_id_usecase.dart';
import 'package:vocabu_rex_mobile/home/domain/usecases/get_user_progress_usecase.dart';

//Event
abstract class HomeEvent {}

class GetUserProgressEvent extends HomeEvent {}

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
  final UserProgressEntity userProgressEntity;
  final SkillEntity? skillEntity;

  HomeSuccess({required this.userProgressEntity, this.skillEntity});

  HomeSuccess copyWith({
    UserProgressEntity? userProgressEntity,
    SkillEntity? skillEntity,
  }) {
    return HomeSuccess(
      userProgressEntity: userProgressEntity ?? this.userProgressEntity,
      skillEntity: skillEntity ?? this.skillEntity,
    );
  }
}

//Bloc
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetUserProgressUsecase getUserProgressUsecase;
  final GetSkillByIdUsecase getSkillByIdUsecase;

  HomeBloc({
    required this.getUserProgressUsecase,
    required this.getSkillByIdUsecase,
  }) : super(HomeInit()) {
    on<GetUserProgressEvent>((event, emit) async {
      emit(HomeLoading());
      try {
        final progress = await getUserProgressUsecase();
        emit(HomeSuccess(userProgressEntity: progress));
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
          final progress = await getUserProgressUsecase();
          final skill = await getSkillByIdUsecase(event.id);

          emit(HomeSuccess(userProgressEntity: progress, skillEntity: skill));
        } catch (e) {
          print(e);
          emit(HomeUnauthen());
        }
      }
    });
  }
}
