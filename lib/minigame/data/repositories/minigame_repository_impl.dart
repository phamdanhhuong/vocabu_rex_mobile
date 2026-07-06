import 'package:vocabu_rex_mobile/exercise/data/models/exercise_model.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_entity.dart';
import 'package:vocabu_rex_mobile/minigame/data/services/minigame_service.dart';
import 'package:vocabu_rex_mobile/minigame/domain/entities/minigame_result_entity.dart';
import 'package:vocabu_rex_mobile/minigame/domain/entities/minigame_session_entity.dart';
import 'package:vocabu_rex_mobile/minigame/domain/entities/minigame_status_entity.dart';
import 'package:vocabu_rex_mobile/minigame/domain/repositories/minigame_repository.dart';

class MiniGameRepositoryImpl implements MiniGameRepository {
  final MiniGameService service;
  MiniGameRepositoryImpl(this.service);

  @override
  Future<MiniGameSessionEntity> getSession({
    required String partId,
    required String gameType,
  }) async {
    final data = await service.getSession(partId: partId, gameType: gameType);

    final rawExercises = (data['exercises'] as List?) ?? [];
    final exercises = rawExercises
        .map((e) {
          try {
            final exerciseJson = Map<String, dynamic>.from(e as Map);
            exerciseJson['isInteractive'] ??= true;
            exerciseJson['isContentBased'] ??= false;
            
            final model = ExerciseModel.fromJson(exerciseJson);
            return ExerciseEntity.fromModel(model);
          } catch (error, stackTrace) {
            print('[MiniGame] Failed to parse exercise: $error');
            print('[MiniGame] Raw data: $e');
            return null;
          }
        })
        .whereType<ExerciseEntity>()
        .toList();

    return MiniGameSessionEntity(
      gameType: data['gameType'] as String,
      partId: data['partId'] as String,
      bestStars: (data['bestStars'] as num?)?.toInt() ?? 0,
      bestScore: (data['bestScore'] as num?)?.toInt() ?? 0,
      bestTimeMs: (data['bestTimeMs'] as num?)?.toInt(),
      totalExercises: exercises.length,
      exercises: exercises,
    );
  }

  @override
  Future<MiniGameResultEntity> submit({
    required String partId,
    required String gameType,
    required int score,
    required int timeSpentMs,
    required int mistakesCount,
  }) async {
    final data = await service.submit(
      partId: partId,
      gameType: gameType,
      score: score,
      timeSpentMs: timeSpentMs,
      mistakesCount: mistakesCount,
    );
    return MiniGameResultEntity.fromJson(
      data,
      score: score,
      timeSpentMs: timeSpentMs,
      mistakesCount: mistakesCount,
    );
  }

  @override
  Future<List<MiniGameStatusEntity>> getStatus(String partId) async {
    final data = await service.getStatus(partId);
    return data
        .map((e) =>
            MiniGameStatusEntity.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
