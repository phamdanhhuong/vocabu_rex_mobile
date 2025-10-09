import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_entity.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/custom_button.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/exercise_header.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/fill_blank.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/listen_choose.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/home_bloc.dart';

class ExercisePage extends StatefulWidget {
  final String lessonId;
  final String lessonTitle;

  const ExercisePage({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
  });

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  int currentExerciseIndex = 0;

  void nextExercise(List<ExerciseEntity> exercises) {
    if (currentExerciseIndex < exercises.length - 1) {
      setState(() {
        currentExerciseIndex++;
      });
    }
  }

  void previousExercise() {
    if (currentExerciseIndex > 0) {
      setState(() {
        currentExerciseIndex--;
      });
    }
  }

  Widget _buildExercise(ExerciseEntity exercise) {
    switch (exercise.exerciseType) {
      case "listen_choose":
        return ListenChoose(
          key: ValueKey(exercise.id),
          meta: exercise.meta as ListenChooseMetaEntity,
          exerciseId: exercise.id,
        );
      case "fill_blank":
        return FillBlank(
          key: ValueKey(exercise.id),
          meta: exercise.meta as FillBlankMetaEntity,
          exerciseId: exercise.id,
        );
      default:
        return Center(
          child: Text(
            'Unsupported exercise type: ${exercise.exerciseType}',
            style: TextStyle(color: AppColors.textBlue),
          ),
        );
    }
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    super.initState();
    context.read<ExerciseBloc>().add(LoadExercises(lessonId: widget.lessonId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseBloc, ExerciseState>(
      builder: (context, state) {
        if (state is ExercisesLoading) {
          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            ),
          );
        }
        if (state is ExercisesLoaded) {
          final exercises = state.lesson.exercises?.toList() ?? [];
          final isCorrect = state.isCorrect;

          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: SafeArea(
              child: Column(
                children: [
                  ExerciseHeader(
                    currentExercise: currentExerciseIndex,
                    totalExercises: exercises.length,
                    lessonTitle: widget.lessonTitle,
                    //onBack: currentExerciseIndex > 0 ? previousExercise : null,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        if (exercises.isNotEmpty)
                          _buildExercise(exercises[currentExerciseIndex]),
                        SizedBox(height: 20),
                        if (isCorrect != null)
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: isCorrect
                                  ? AppColors.backgroundLightGreen
                                  : AppColors.backgroundLightRed,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Column(
                              children: [
                                SizedBox(height: 50),
                                isCorrect
                                    ? Text(
                                        "Chính xác !!!",
                                        style: TextStyle(
                                          color: AppColors.primaryGreen,
                                          fontSize: 32,
                                        ),
                                      )
                                    : Text(
                                        "Sai rồi !!!",
                                        style: TextStyle(
                                          color: AppColors.primaryRed,
                                          fontSize: 32,
                                        ),
                                      ),
                                Spacer(),
                                CustomButton(
                                  color: isCorrect
                                      ? AppColors.primaryGreen
                                      : AppColors.primaryRed,
                                  onTap: () {
                                    if (exercises != null) {
                                      if (currentExerciseIndex <
                                          exercises.length - 1) {
                                        nextExercise(exercises);
                                        context.read<ExerciseBloc>().add(
                                          AnswerClear(),
                                        );
                                        if (currentExerciseIndex ==
                                            exercises.length - 1) {
                                          context.read<ExerciseBloc>().add(
                                            SubmitResult(),
                                          );
                                        }
                                        ;
                                      }
                                    }
                                  },
                                  label: "Tiếp tục",
                                ),
                              ],
                            ),
                          ),
                        ElevatedButton(
                          onPressed: () {
                            nextExercise(exercises);
                          },
                          child: Text("Tiếp tục"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is ExercisesSubmitted) {
          return Scaffold(
            backgroundColor: state.isSuccess
                ? AppColors.backgroundLightGreen
                : AppColors.backgroundLightGreen,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.isSuccess ? "Thành công" : "Thất bại",
                    style: TextStyle(
                      color: state.isSuccess
                          ? AppColors.primaryGreen
                          : AppColors.primaryRed,
                      fontSize: 32,
                    ),
                  ),
                  CustomButton(
                    color: state.isSuccess
                        ? AppColors.primaryGreen
                        : AppColors.primaryRed,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.read<HomeBloc>().add(GetUserProfileEvent());
                    },
                    label: "Quay về trang chính",
                  ),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: Center(
            child: Text(
              'Unknown state',
              style: TextStyle(color: AppColors.textBlue),
            ),
          ),
        );
      },
    );
  }
}
