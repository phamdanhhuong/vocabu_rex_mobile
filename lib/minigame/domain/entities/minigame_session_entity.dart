import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_entity.dart';

/// Entity cho 1 phiên chơi minigame (nhận từ API /play)
class MiniGameSessionEntity {
  final String gameType; // ARCADE | PUZZLE
  final String partId;
  final int bestStars;
  final int bestScore;
  final int? bestTimeMs;
  final int totalExercises;
  final List<ExerciseEntity> exercises;

  const MiniGameSessionEntity({
    required this.gameType,
    required this.partId,
    required this.bestStars,
    required this.bestScore,
    this.bestTimeMs,
    required this.totalExercises,
    required this.exercises,
  });
}
