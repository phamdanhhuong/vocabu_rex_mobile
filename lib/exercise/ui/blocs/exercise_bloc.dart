//Event
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/entities.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/get_exercise_usecase.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/get_image_description_score.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/get_review_exercise_usecase.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/get_speak_point.dart';
import 'package:vocabu_rex_mobile/exercise/domain/usecases/submit_lesson_usecase.dart';
import 'package:vocabu_rex_mobile/energy/domain/usecases/consume_energy_usecase.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/lesson_entity.dart';
import 'package:vocabu_rex_mobile/energy/ui/blocs/energy_bloc.dart';

abstract class ExerciseEvent {}

class LoadExercises extends ExerciseEvent {
  final String lessonId;

  LoadExercises({required this.lessonId});
}

class LoadReviewExercises extends ExerciseEvent {
  LoadReviewExercises();
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

class DescriptionCheck extends ExerciseEvent {
  final String content;
  final String expectResult;
  final String exerciseId;

  DescriptionCheck({
    required this.content,
    required this.expectResult,
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
  final bool isReview;

  ExercisesLoaded({
    required this.lesson,
    this.isCorrect,
    this.result,
    this.isReview = false,
  });

  ExercisesLoaded copyWith({
    LessonEntity? lesson,
    bool? isCorrect,
    ExerciseResultEntity? result,
    bool? isReview,
  }) {
    return ExercisesLoaded(
      lesson: lesson ?? this.lesson,
      isCorrect: isCorrect,
      result: result ?? this.result,
      isReview: isReview ?? this.isReview,
    );
  }
}

class ExercisesSubmitted extends ExerciseState {
  final SubmitResponseEntity submitResponse;
  ExercisesSubmitted({required this.submitResponse});
}

//Bloc
class ExerciseBloc extends Bloc<ExerciseEvent, ExerciseState> {
  final GetExerciseUseCase getExerciseUseCase;
  final GetReviewExerciseUsecase getReviewExerciseUsecase;
  final SubmitLessonUsecase submitLessonUsecase;
  final GetSpeakPoint getSpeakPoint;
  final GetImageDescriptionScore getImageDescriptionScore;
  final ConsumeEnergyUseCase? consumeEnergyUseCase;
  final EnergyBloc energyBloc;
  ExerciseBloc({
    required this.getExerciseUseCase,
    required this.getReviewExerciseUsecase,
    required this.submitLessonUsecase,
    required this.getSpeakPoint,
    required this.getImageDescriptionScore,
    this.consumeEnergyUseCase,
    required this.energyBloc,
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

    on<LoadReviewExercises>((event, emit) async {
      emit(ExercisesLoading());
      final lesson = await getReviewExerciseUsecase();
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

      emit(ExercisesLoaded(lesson: lesson, result: result, isReview: true));
    });

    on<AnswerSelected>((event, emit) async {
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

        // Handle energy consumption for incorrect answers
        if (!isCorrect) {
          await _handleEnergyConsumption(
            event.exerciseId,
            currentState.isReview,
          );
        }
      }
    });

    on<FilledBlank>((event, emit) async {
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

        // Handle energy consumption for incorrect answers
        if (!isCorrect) {
          await _handleEnergyConsumption(
            event.exerciseId,
            currentState.isReview,
          );
        }
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
        final submitResponse = await submitLessonUsecase(currentState.result!);
        emit(ExercisesSubmitted(submitResponse: submitResponse));
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

        // Handle energy consumption for incorrect answers
        if (!isCorrect) {
          await _handleEnergyConsumption(
            event.exerciseId,
            currentState.isReview,
          );
        }
      }
    });

    on<DescriptionCheck>((event, emit) async {
      final currentState = state;
      if (currentState is ExercisesLoaded) {
        bool isCorrect = true;
        final result = await getImageDescriptionScore(
          event.content,
          event.expectResult,
        );
        if (!result.isCorrect) {
          isCorrect = false;
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

        // Handle energy consumption for incorrect answers
        if (!isCorrect) {
          await _handleEnergyConsumption(
            event.exerciseId,
            currentState.isReview,
          );
        }
      }
    });
  }

  /// Handle energy consumption for incorrect answers
  Future<void> _handleEnergyConsumption(
    String exerciseId,
    bool isReview,
  ) async {
    // Don't consume energy if it's a review session
    if (isReview || consumeEnergyUseCase == null) {
      return;
    }

    try {
      final idempotencyKey =
          '$exerciseId-${DateTime.now().millisecondsSinceEpoch}';
      final resp = await consumeEnergyUseCase!.call(
        amount: 1,
        referenceId: exerciseId,
        idempotencyKey: idempotencyKey,
        reason: 'EXERCISE_INCORRECT',
        activityType: 'exercise',
        metadata: {'exerciseId': exerciseId},
      );

      // Refresh energy status so UI updates for this user — do it regardless of result
      energyBloc.add(GetEnergyStatusEvent());

      // If server indicates insufficient energy or remainingEnergy <= 0, submit the lesson
      if (resp.success == false &&
          resp.error != null &&
          resp.error!.toLowerCase().contains('insufficient')) {
        // submit the lesson immediately
        add(SubmitResult());
      } else if (resp.remainingEnergy <= 0) {
        add(SubmitResult());
      }
    } catch (e) {
      // swallow errors here; UI can fetch updated energy separately or react to insufficient event
      // Optionally: emit a state that indicates insufficient energy
    }
  }
}
