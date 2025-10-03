//Event
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/get_exercise_usecase.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/lesson_entity.dart';

abstract class ExerciseEvent {}

class LoadExercises extends ExerciseEvent {
  final String lessonId;

  LoadExercises({required this.lessonId});
}

//State
abstract class ExerciseState {}

class ExercisesLoading extends ExerciseState {}

class ExercisesLoaded extends ExerciseState {
  final LessonEntity lesson;
  ExercisesLoaded({required this.lesson});
}

//Bloc
class ExerciseBloc extends Bloc<ExerciseEvent, ExerciseState> {
  final GetExerciseUseCase getExerciseUseCase;
  ExerciseBloc({required this.getExerciseUseCase}) : super(ExercisesLoading()) {
    on<LoadExercises>((event, emit) async {
      emit(ExercisesLoading());
      final lesson = await getExerciseUseCase(event.lessonId);
      emit(ExercisesLoaded(lesson: lesson));
    });
  }
}
