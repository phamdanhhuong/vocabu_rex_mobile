import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_part_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/user_progress_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/usecases/get_skill_by_id_usecase.dart';
import 'package:vocabu_rex_mobile/home/domain/usecases/get_skill_part_usecase.dart';
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
  final List<SkillPartEntity>? skillPartEntities;
  HomeSuccess({
    required this.userProgressEntity,
    this.skillEntity,
    this.skillPartEntities,
  });

  HomeSuccess copyWith({
    UserProgressEntity? userProgressEntity,
    SkillEntity? skillEntity,
    List<SkillPartEntity>? skillPartEntities,
  }) {
    return HomeSuccess(
      userProgressEntity: userProgressEntity ?? this.userProgressEntity,
      skillEntity: skillEntity ?? this.skillEntity,
      skillPartEntities: skillPartEntities ?? this.skillPartEntities,
    );
  }
}

//Bloc
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetUserProgressUsecase getUserProgressUsecase;
  final GetSkillByIdUsecase getSkillByIdUsecase;
  final GetSkillPartUsecase getSkillPartUsecase;

  HomeBloc({
    required this.getUserProgressUsecase,
    required this.getSkillByIdUsecase,
    required this.getSkillPartUsecase,
  }) : super(HomeInit()) {
    on<GetUserProgressEvent>((event, emit) async {
      emit(HomeLoading());
      try {
        final progress = await getUserProgressUsecase();
        final skillParts = await getSkillPartUsecase();
        emit(
          HomeSuccess(
            userProgressEntity: progress,
            skillPartEntities: skillParts,
          ),
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
