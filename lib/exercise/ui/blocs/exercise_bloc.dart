//Event
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/entities.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/get_exercise_usecase.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/get_speak_point.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/submit_lesson_usecase.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/lesson_entity.dart';

abstract class ExerciseEvent {}

class LoadExercises extends ExerciseEvent {
  final String lessonId;

  LoadExercises({required this.lessonId});
}

class AnswerSelected extends ExerciseEvent {
  final String selectedAnswer;
  final String correctAnswer;
  final String exerciseId;

  AnswerSelected({
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.exerciseId,
  });
}

class SpeakCheck extends ExerciseEvent {
  final String path;
  final String referenceText;
  final String exerciseId;

  SpeakCheck({
    required this.path,
    required this.referenceText,
    required this.exerciseId,
  });
}

class FilledBlank extends ExerciseEvent {
  final List<String> listAnswer;
  final List<String> listCorrectAnswer;
  final String exerciseId;

  FilledBlank({
    required this.listAnswer,
    required this.listCorrectAnswer,
    required this.exerciseId,
  });
}

class AnswerClear extends ExerciseEvent {}

class SubmitResult extends ExerciseEvent {}

//State
abstract class ExerciseState {}

class ExercisesLoading extends ExerciseState {}

class ExercisesLoaded extends ExerciseState {
  final LessonEntity lesson;
  final bool? isCorrect; // null = chưa chọn, true/false = kết quả
  final ExerciseResultEntity? result;

  ExercisesLoaded({required this.lesson, this.isCorrect, this.result});

  ExercisesLoaded copyWith({
    LessonEntity? lesson,
    bool? isCorrect,
    ExerciseResultEntity? result,
  }) {
    return ExercisesLoaded(
      lesson: lesson ?? this.lesson,
      isCorrect: isCorrect,
      result: result ?? this.result,
    );
  }
}

class ExercisesSubmitted extends ExerciseState {
  final bool isSuccess;
  ExercisesSubmitted({required this.isSuccess});
}

//Bloc
class ExerciseBloc extends Bloc<ExerciseEvent, ExerciseState> {
  final GetExerciseUseCase getExerciseUseCase;
  final SubmitLessonUsecase submitLessonUsecase;
  final GetSpeakPoint getSpeakPoint;
  ExerciseBloc({
    required this.getExerciseUseCase,
    required this.submitLessonUsecase,
    required this.getSpeakPoint,
  }) : super(ExercisesLoading()) {
    on<LoadExercises>((event, emit) async {
      emit(ExercisesLoading());
      final lesson = await getExerciseUseCase(event.lessonId);
      // Tạo result với các exercise answers mặc định
      final result = ExerciseResultEntity(
        lessonId: lesson.id,
        skillId: lesson.skillId,
        exercises:
            lesson.exercises
                ?.map(
                  (exercise) => ExerciseAnswerEntity(
                    exerciseId: exercise.id,
                    isCorrect: false,
                    incorrectCount: 0,
                  ),
                )
                .toList() ??
            [],
      );

      emit(ExercisesLoaded(lesson: lesson, result: result));
    });

    on<AnswerSelected>((event, emit) {
      final currentState = state;
      if (currentState is ExercisesLoaded) {
        final isCorrect = event.selectedAnswer == event.correctAnswer;

        // Cập nhật result với đáp án của exercise hiện tại
        ExerciseResultEntity? updatedResult;
        if (currentState.result != null) {
          final updatedExercises = currentState.result!.exercises.map((answer) {
            if (answer.exerciseId == event.exerciseId) {
              return answer.copyWith(
                isCorrect: isCorrect,
                incorrectCount: isCorrect
                    ? answer.incorrectCount
                    : answer.incorrectCount + 1,
              );
            }
            return answer;
          }).toList();

          updatedResult = currentState.result!.copyWith(
            exercises: updatedExercises,
          );
        }

        emit(
          currentState.copyWith(isCorrect: isCorrect, result: updatedResult),
        );
      }
    });

    on<FilledBlank>((event, emit) {
      final currentState = state;
      if (currentState is ExercisesLoaded) {
        bool isCorrect = true;
        for (int i = 0; i < event.listAnswer.length; i++) {
          if (event.listAnswer[i] != event.listCorrectAnswer[i]) {
            isCorrect = false;
            break;
          }
        }
        // Cập nhật result với đáp án của exercise hiện tại
        ExerciseResultEntity? updatedResult;
        if (currentState.result != null) {
          final updatedExercises = currentState.result!.exercises.map((answer) {
            if (answer.exerciseId == event.exerciseId) {
              return answer.copyWith(
                isCorrect: isCorrect,
                incorrectCount: isCorrect
                    ? answer.incorrectCount
                    : answer.incorrectCount + 1,
              );
            }
            return answer;
          }).toList();

          updatedResult = currentState.result!.copyWith(
            exercises: updatedExercises,
          );
        }

        emit(
          currentState.copyWith(isCorrect: isCorrect, result: updatedResult),
        );
      }
    });

    on<AnswerClear>((event, emit) {
      final currentState = state;
      if (currentState is ExercisesLoaded) {
        emit(currentState.copyWith(isCorrect: null));
      }
    });

    on<SubmitResult>((event, emit) async {
      final currentState = state;
      emit(ExercisesLoading());
      if (currentState is ExercisesLoaded && currentState.result != null) {
        final result = await submitLessonUsecase(currentState.result!);
        emit(ExercisesSubmitted(isSuccess: result));
      }
    });

    on<SpeakCheck>((event, emit) async {
      final currentState = state;
      if (currentState is ExercisesLoaded) {
        bool isCorrect = true;
        final result = await getSpeakPoint(event.path, event.referenceText);
        for (WordComparisonEntity wordComparison in result.wordComparisons) {
          if (wordComparison.wordMatch == false) {
            isCorrect = false;
            break;
          }
        }
        // Cập nhật result với đáp án của exercise hiện tại
        ExerciseResultEntity? updatedResult;
        if (currentState.result != null) {
          final updatedExercises = currentState.result!.exercises.map((answer) {
            if (answer.exerciseId == event.exerciseId) {
              return answer.copyWith(
                isCorrect: isCorrect,
                incorrectCount: isCorrect
                    ? answer.incorrectCount
                    : answer.incorrectCount + 1,
              );
            }
            return answer;
          }).toList();

          updatedResult = currentState.result!.copyWith(
            exercises: updatedExercises,
          );
        }

        emit(
          currentState.copyWith(isCorrect: isCorrect, result: updatedResult),
        );
      }
    });
  }
}
