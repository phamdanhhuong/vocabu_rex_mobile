import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/exercises/index.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/warp_speed_loading_screen.dart';
import 'package:vocabu_rex_mobile/minigame/ui/blocs/minigame_bloc.dart';
import 'package:vocabu_rex_mobile/minigame/ui/pages/minigame_result_page.dart';
import 'package:vocabu_rex_mobile/minigame/ui/widgets/minigame_timer_widget.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/core/interaction_service.dart';
import 'package:vocabu_rex_mobile/core/injection.dart';

class MiniGamePlayPage extends StatefulWidget {
  final String partId;
  final String gameType;
  final String milestoneName;

  const MiniGamePlayPage({
    super.key,
    required this.partId,
    required this.gameType,
    required this.milestoneName,
  });

  @override
  State<MiniGamePlayPage> createState() => _MiniGamePlayPageState();
}

class _MiniGamePlayPageState extends State<MiniGamePlayPage> {
  int _exerciseResetCounter = 0;
  int _lastExerciseIndex = 0;
  bool? _lastProcessedCorrect;
  bool _isMinLoadingMet = false;

  bool get isArcade => widget.gameType == 'ARCADE';

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    // Load session
    context.read<MiniGameBloc>().add(LoadMiniGameSessionEvent(
          partId: widget.partId,
          gameType: widget.gameType,
        ));

    // Minimum loading animation
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _isMinLoadingMet = true);
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  void _onAnswerCorrect(MiniGameLoaded state) {
    InteractionService.playSuccess();
    context.read<MiniGameBloc>().add(MiniGameAnswerEvent(true));
    // Auto advance sau 600ms
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _advance(state);
    });
  }

  void _onAnswerWrong(MiniGameLoaded state) {
    InteractionService.playError();
    context.read<MiniGameBloc>().add(MiniGameAnswerEvent(false));
    // Advance sau 1 giây để user thấy kết quả sai
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _advance(state);
    });
  }

  void _advance(MiniGameLoaded state) {
    final nextIndex = state.currentIndex + 1;
    if (nextIndex >= state.session.exercises.length) {
      // Hết câu — submit
      _submit(state);
    } else {
      setState(() {
        _lastExerciseIndex = state.currentIndex;
        _exerciseResetCounter++;
        _lastProcessedCorrect = null;
      });
      context.read<MiniGameBloc>().add(MiniGameNextQuestionEvent());
    }
  }

  void _submit(MiniGameLoaded state) {
    context.read<MiniGameBloc>().add(SubmitMiniGameEvent(
          partId: widget.partId,
          gameType: widget.gameType,
          score: state.score,
          timeSpentMs: state.timeSpentMs,
          mistakesCount: state.mistakesCount,
        ));
  }

  Widget _buildExercise(ExerciseEntity exercise, MiniGameLoaded state) {
    final uniqueKey = ValueKey('${exercise.id}_$_exerciseResetCounter');

    // Wrapper để intercept exercise bloc events và convert sang MiniGameBloc events
    void onContinue() {
      // Continue là sau khi user bấm tiếp tục — chúng ta advance
      _advance(state);
    }

    switch (exercise.exerciseType) {
      case 'listen_choose':
        if (exercise.meta is! ListenChooseMetaEntity) break;
        return ListenChoose(
          key: uniqueKey,
          meta: exercise.meta as ListenChooseMetaEntity,
          exerciseId: exercise.id,
          onContinue: onContinue,
        );
      case 'multiple_choice':
        if (exercise.meta is! MultipleChoiceMetaEntity) break;
        return MultipleChoice(
          key: uniqueKey,
          meta: exercise.meta as MultipleChoiceMetaEntity,
          exerciseId: exercise.id,
          onContinue: onContinue,
        );
      case 'match':
        if (exercise.meta is! MatchMetaEntity) break;
        return MatchExercise(
          key: uniqueKey,
          meta: exercise.meta as MatchMetaEntity,
          exerciseId: exercise.id,
          onContinue: onContinue,
        );
      case 'translate':
        if (exercise.meta is! TranslateMetaEntity) break;
        return Translate(
          key: uniqueKey,
          meta: exercise.meta as TranslateMetaEntity,
          exerciseId: exercise.id,
          onContinue: onContinue,
        );
      case 'fill_blank':
        if (exercise.meta is! FillBlankMetaEntity) break;
        return FillBlank(
          key: uniqueKey,
          meta: exercise.meta as FillBlankMetaEntity,
          exerciseId: exercise.id,
          onContinue: onContinue,
        );
      default:
        break; // Auto skip
    }

    // Unsupported type or invalid meta — auto skip
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _advance(state);
    });
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExerciseBloc>(
      create: (_) => sl<ExerciseBloc>(),
      child: BlocListener<MiniGameBloc, MiniGameState>(
        listener: (context, state) {
          if (state is MiniGameCompleted) {
            // Navigate to result page
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => MiniGameResultPage(
                  result: state.result,
                  gameType: widget.gameType,
                  partId: widget.partId,
                  milestoneName: widget.milestoneName,
                ),
              ),
            );
          } else if (state is MiniGameLoaded &&
              state.isCorrect != null &&
              state.isCorrect != _lastProcessedCorrect) {
            _lastProcessedCorrect = state.isCorrect;
            if (state.isCorrect!) {
              _onAnswerCorrect(state);
            } else {
              _onAnswerWrong(state);
            }
          }
        },
        child: BlocBuilder<MiniGameBloc, MiniGameState>(
          builder: (context, state) {
            if (state is MiniGameLoading || !_isMinLoadingMet) {
              return const WarpSpeedLoadingScreen();
            }

            if (state is MiniGameError) {
              return Scaffold(
                backgroundColor: AppColors.background,
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 64, color: Colors.redAccent),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.bodyText),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Quay lại'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            if (state is MiniGameLoaded) {
              if (state.isFinished || state is MiniGameSubmitting) {
                return const Scaffold(
                  backgroundColor: Color(0xFF0A0A1A),
                  body: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );
              }

              final exercises = state.session.exercises;
              final currentExercise = exercises[state.currentIndex];
              final progress =
                  (state.currentIndex + 1) / exercises.length;

              return Scaffold(
                backgroundColor: AppColors.background,
                body: SafeArea(
                  child: Column(
                    children: [
                      // ── Header ──────────────────────────────────────
                      _buildHeader(context, state, progress),

                      // ── Exercise area ───────────────────────────────
                      Expanded(
                        child: BlocListener<ExerciseBloc, ExerciseState>(
                          listenWhen: (_, current) =>
                              current is ExercisesLoaded &&
                              current.isCorrect != null,
                          listener: (context, exState) {
                            if (exState is ExercisesLoaded &&
                                exState.isCorrect != null &&
                                exState.isCorrect != _lastProcessedCorrect) {
                              _lastProcessedCorrect = exState.isCorrect;
                              if (exState.isCorrect!) {
                                _onAnswerCorrect(state);
                              } else {
                                _onAnswerWrong(state);
                              }
                            }
                          },
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 450),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, animation) {
                              final forward = state.currentIndex >= _lastExerciseIndex;
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: Offset(forward ? 0.25 : -0.25, 0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              key: ValueKey(
                                  '${currentExercise.id}_$_exerciseResetCounter'),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 0),
                              child: _buildExercise(currentExercise, state),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, MiniGameLoaded state, double progress) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              // Close button
              IconButton(
                icon: const Icon(Icons.close, size: 22),
                color: AppColors.bodyText,
                padding: EdgeInsets.zero,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Thoát game?'),
                      content: const Text(
                          'Tiến độ hiện tại sẽ không được lưu.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Ở lại'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          child: const Text('Thoát',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(width: 8),

              // Progress bar
              Expanded(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.swan,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isArcade
                              ? const Color(0xFFFF6B35)
                              : const Color(0xFF7C4DFF),
                        ),
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${state.currentIndex + 1} / ${state.session.exercises.length}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.hare,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Timer/mistakes widget
              MiniGameTimerWidget(
                isArcade: isArcade,
                mistakesCount: state.mistakesCount,
              ),
            ],
          ),

          // Score chip
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${state.score} điểm',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
