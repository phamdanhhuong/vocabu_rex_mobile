import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_entity.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/custom_button.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/exercise_header.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/reward_summary.dart';
import 'package:vocabu_rex_mobile/exercise/ui/pages/reward_collect_page.dart';
import 'package:vocabu_rex_mobile/energy/ui/widgets/energy_display.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/exercises/index.dart';
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
  Set<int> reDoIndexs = <int>{};
  bool isRedoPhase = false;
  List<int> redoQueue = [];

  void nextExercise(List<ExerciseEntity> exercises) {
    // if (currentExerciseIndex < exercises.length - 1) {
    //   setState(() {
    //     currentExerciseIndex++;
    //   });
    // }
    if (isRedoPhase) {
      // đang trong redo phase
      final redoPos = redoQueue.indexOf(currentExerciseIndex);
      if (redoPos < redoQueue.length - 1) {
        // còn bài tiếp trong redo
        setState(() {
          currentExerciseIndex = redoQueue[redoPos + 1];
        });
      } else {
        // hết redo phase
        if (reDoIndexs.isEmpty) {
          setState(() {
            isRedoPhase = false;
          });
          context.read<ExerciseBloc>().add(SubmitResult());
        } else {
          // có bài sai mới trong redo phase hiện tại → lặp redo nữa
          setState(() {
            redoQueue = reDoIndexs.toList();
            reDoIndexs.clear();
            currentExerciseIndex = redoQueue.first;
          });
        }
      }
    } else {
      // đang trong phase bình thường
      if (currentExerciseIndex < exercises.length - 1) {
        setState(() {
          currentExerciseIndex++;
        });
      } else {
        if (reDoIndexs.isNotEmpty) {
          // chuyển sang redo
          setState(() {
            isRedoPhase = true;
            redoQueue = reDoIndexs.toList();
            reDoIndexs.clear();
            currentExerciseIndex = redoQueue.first;
          });
        } else {
          context.read<ExerciseBloc>().add(SubmitResult());
        }
      }
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
      case "match":
        return MatchExercise(
          key: ValueKey(exercise.id),
          meta: exercise.meta as MatchMetaEntity,
          exerciseId: exercise.id,
        );
      case "multiple_choice":
        return MultipleChoice(
          key: ValueKey(exercise.id),
          meta: exercise.meta as MultipleChoiceMetaEntity,
          exerciseId: exercise.id,
        );
      case "podcast":
        return Podcast(
          key: ValueKey(exercise.id),
          meta: exercise.meta as PodcastMetaEntity,
          exerciseId: exercise.id,
        );
      case "speak":
        return Speak(
          key: ValueKey(exercise.id),
          meta: exercise.meta as SpeakMetaEntity,
          exerciseId: exercise.id,
        );
      case "translate":
        return Translate(
          key: ValueKey(exercise.id),
          meta: exercise.meta as TranslateMetaEntity,
          exerciseId: exercise.id,
        );
      case "image_description":
        return ImageDescription(
          key: ValueKey(exercise.id),
          meta: exercise.meta as ImageDescriptionMetaEntity,
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
                    isRedoPhase: isRedoPhase,
                    //onBack: currentExerciseIndex > 0 ? previousExercise : null,
                    trailing: EnergyDisplay(),
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
                                    if (!isCorrect) {
                                      reDoIndexs.add(currentExerciseIndex);
                                    } else {
                                      reDoIndexs.remove(currentExerciseIndex);
                                    }
                                    context.read<ExerciseBloc>().add(
                                      AnswerClear(),
                                    );
                                    nextExercise(exercises);
                                    // if (currentExerciseIndex <
                                    //     exercises.length - 1) {
                                    //   nextExercise(exercises);
                                    //   if (currentExerciseIndex ==
                                    //           exercises.length - 1 &&
                                    //       reDoIndexs.isEmpty) {
                                    //     context.read<ExerciseBloc>().add(
                                    //       SubmitResult(),
                                    //     );
                                    //   } else {}
                                    // }
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
          return RewardSummary(
            response: state.submitResponse,
            onAccept: () async {
              // Navigate to collect page, wait for result then pop and refresh
              final collected = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => RewardCollectPage(
                    response: state.submitResponse,
                    // if you have an asset path put here
                    imageAsset: null,
                  ),
                ),
              );

              // After collecting, go back and refresh home progress
              if (collected == true) {
                Navigator.of(context).pop();
                context.read<HomeBloc>().add(GetUserProgressEvent());
              } else {
                Navigator.of(context).pop();
                context.read<HomeBloc>().add(GetUserProgressEvent());
              }
            },
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
