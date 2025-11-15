import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_entity.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/enhanced_podcast_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
// custom_button not needed here; exercises render their own controls now
import 'package:vocabu_rex_mobile/theme/colors.dart';
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
  int _lastExerciseIndex = 0;
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
          _lastExerciseIndex = currentExerciseIndex;
          currentExerciseIndex = redoQueue[redoPos + 1];
        });
          // Ensure the bloc's transient result state is cleared for the newly shown exercise
          context.read<ExerciseBloc>().add(AnswerClear());
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
            _lastExerciseIndex = currentExerciseIndex;
            redoQueue = reDoIndexs.toList();
            reDoIndexs.clear();
            currentExerciseIndex = redoQueue.first;
          });
            // Clear transient answer state before rendering the new exercise
            context.read<ExerciseBloc>().add(AnswerClear());
        }
      }
    } else {
      // đang trong phase bình thường
      if (currentExerciseIndex < exercises.length - 1) {
        setState(() {
          _lastExerciseIndex = currentExerciseIndex;
          currentExerciseIndex++;
        });
          // Clear transient result so the next exercise doesn't reuse previous isCorrect
          context.read<ExerciseBloc>().add(AnswerClear());
      } else {
        if (reDoIndexs.isNotEmpty) {
          // chuyển sang redo
          setState(() {
            _lastExerciseIndex = currentExerciseIndex;
            isRedoPhase = true;
            redoQueue = reDoIndexs.toList();
            reDoIndexs.clear();
            currentExerciseIndex = redoQueue.first;
          });
            // Clear transient answer state before showing redo exercise
            context.read<ExerciseBloc>().add(AnswerClear());
        } else {
          context.read<ExerciseBloc>().add(SubmitResult());
        }
      }
    }
  }

  void previousExercise() {
    if (currentExerciseIndex > 0) {
      setState(() {
        _lastExerciseIndex = currentExerciseIndex;
        currentExerciseIndex--;
      });
    }
  }

  Widget _buildExercise(ExerciseEntity exercise, [VoidCallback? onContinue]) {
    switch (exercise.exerciseType) {
      case "listen_choose":
        return ListenChoose(
          key: ValueKey(exercise.id),
          meta: exercise.meta as ListenChooseMetaEntity,
          exerciseId: exercise.id,
          onContinue: onContinue,
        );
      case "fill_blank":
        return FillBlank(
          key: ValueKey(exercise.id),
          meta: exercise.meta as FillBlankMetaEntity,
          exerciseId: exercise.id,
          onContinue: onContinue,
        );
      case "match":
        return MatchExercise(
          key: ValueKey(exercise.id),
          meta: exercise.meta as MatchMetaEntity,
          exerciseId: exercise.id,
          onContinue: onContinue,
        );
      case "multiple_choice":
        return MultipleChoice(
          key: ValueKey(exercise.id),
          meta: exercise.meta as MultipleChoiceMetaEntity,
          exerciseId: exercise.id,
          onContinue: onContinue,
        );
      case "podcast":
        return EnhancedPodcast(
          key: ValueKey(exercise.id),
          meta: exercise.meta as EnhancedPodcastMetaEntity,
          exerciseId: exercise.id,
        );
      case "speak":
        return Speak(
          key: ValueKey(exercise.id),
          meta: exercise.meta as SpeakMetaEntity,
          exerciseId: exercise.id,
          onContinue: onContinue,
        );
      case "translate":
        return Translate(
          key: ValueKey(exercise.id),
          meta: exercise.meta as TranslateMetaEntity,
          exerciseId: exercise.id,
          onContinue: onContinue,
        );
      case "image_description":
        return ImageDescription(
          key: ValueKey(exercise.id),
          meta: exercise.meta as ImageDescriptionMetaEntity,
          exerciseId: exercise.id,
          onContinue: onContinue,
        );
      case "writing_prompt":
        return WritingPrompt(
          key: ValueKey(exercise.id),
          meta: exercise.meta as WritingPromptMetaEntity,
          exerciseId: exercise.id,
          onContinue: onContinue,
        );
      default:
        return Center(
          child: Text(
            'Unsupported exercise type: ${exercise.exerciseType}',
            style: TextStyle(color: AppColors.humpback),
          ),
        );
    }
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    super.initState();
    if (widget.lessonId != "review") {
      context.read<ExerciseBloc>().add(
        LoadExercises(lessonId: widget.lessonId),
      );
    } else {
      context.read<ExerciseBloc>().add(LoadReviewExercises());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseBloc, ExerciseState>(
      builder: (context, state) {
        if (state is ExercisesLoading) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (state is ExercisesLoaded) {
          final exercises = state.lesson.exercises?.toList() ?? [];
          // exercise widgets receive and react to the bloc state themselves

          return Scaffold(
            backgroundColor: AppColors.background,
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
                          // Constrain the exercise widget to the available vertical space
                          // so large exercise widgets (like MatchExercise) don't overflow
                          // the Column. AnimatedSwitcher itself doesn't constrain size,
                          // so wrap it with Expanded.
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) {
                                final bool isForward = currentExerciseIndex >= _lastExerciseIndex;
                                final Offset beginOffset = isForward ? const Offset(0.12, 0) : const Offset(-0.12, 0);
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: _buildExercise(exercises[currentExerciseIndex], () => nextExercise(exercises)),
                            ),
                          ),
                        SizedBox(height: 20),
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
          backgroundColor: AppColors.background,
          body: Center(
            child: Text(
              'Unknown state',
              style: TextStyle(color: AppColors.humpback),
            ),
          ),
        );
      },
    );
  }
}
