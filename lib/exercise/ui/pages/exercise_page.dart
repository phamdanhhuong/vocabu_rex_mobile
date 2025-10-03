import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';

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
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.lessonTitle,
              style: TextStyle(color: AppColors.textBlue),
            ),
            backgroundColor: AppColors.appBarColor,
          ),
          backgroundColor: AppColors.backgroundColor,
          body: Center(
            child: Text(
              'Exercise content for lesson ${widget.lessonId}',
              style: TextStyle(color: AppColors.textBlue),
            ),
          ),
        );
      },
    );
  }
}
