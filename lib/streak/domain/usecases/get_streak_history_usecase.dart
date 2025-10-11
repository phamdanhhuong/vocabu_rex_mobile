import 'package:vocabu_rex_mobile/streak/domain/entities/get_streak_history_response_entity.dart';
import 'package:vocabu_rex_mobile/streak/domain/repositories/streak_repository.dart';

class GetStreakHistoryUseCase {
  final StreakRepository repository;

  GetStreakHistoryUseCase({required this.repository});

  Future<GetStreakHistoryResponseEntity> call({int? limit, bool? includeCurrentStreak}) {
    return repository.getStreakHistory(limit: limit, includeCurrentStreak: includeCurrentStreak);
  }
}
