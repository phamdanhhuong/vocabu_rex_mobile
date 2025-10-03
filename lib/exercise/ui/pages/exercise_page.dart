import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_entity.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/exercise_header.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/listen_choose.dart';

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
    } else {
      // TODO: xử lý khi xong hết bài (ví dụ show dialog hoàn thành)
      _showLessonCompleteDialog();
    }
  }

  void previousExercise() {
    if (currentExerciseIndex > 0) {
      setState(() {
        currentExerciseIndex--;
      });
    }
  }

  void _showLessonCompleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Lesson Complete!',
            style: TextStyle(color: AppColors.textBlue),
          ),
          content: Text(
            'Congratulations! You have completed all exercises in this lesson.',
            style: TextStyle(color: AppColors.textBlue),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: Text(
                'OK',
                style: TextStyle(color: AppColors.primaryGreen),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExercise(ExerciseEntity exercise) {
    switch (exercise.exerciseType) {
      case "listen_choose":
        return ListenChoose(meta: exercise.meta as ListenChooseMetaEntity);
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

          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: SafeArea(
              child: Column(
                children: [
                  ExerciseHeader(
                    currentExercise: currentExerciseIndex,
                    totalExercises: exercises.length,
                    lessonTitle: widget.lessonTitle,
                    onBack: currentExerciseIndex > 0 ? previousExercise : null,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        if (exercises.isNotEmpty)
                          _buildExercise(exercises[currentExerciseIndex]),
                        SizedBox(height: 20),
                        if (exercises.isNotEmpty)
                          ElevatedButton(
                            onPressed: () => nextExercise(exercises),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                            ),
                            child: Text(
                              currentExerciseIndex < exercises.length - 1
                                  ? 'Next Exercise'
                                  : 'Finish Lesson',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        ;
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
