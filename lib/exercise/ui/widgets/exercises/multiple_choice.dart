import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/exercises/multiple_choice_simple.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/exercises/multiple_choice_complex.dart';

class MultipleChoice extends StatelessWidget {
  final MultipleChoiceMetaEntity meta;
  final String exerciseId;
  final VoidCallback? onContinue;
  
  const MultipleChoice({
    super.key,
    required this.meta,
    required this.exerciseId,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    // If correctOrder has only 1 element, use simple UI
    // Otherwise use complex UI with animations
    if (meta.correctOrder.length == 1) {
      return MultipleChoiceSimple(
        meta: meta,
        exerciseId: exerciseId,
        onContinue: onContinue,
      );
    } else {
      return MultipleChoiceComplex(
        meta: meta,
        exerciseId: exerciseId,
        onContinue: onContinue,
      );
    }
  }
}
