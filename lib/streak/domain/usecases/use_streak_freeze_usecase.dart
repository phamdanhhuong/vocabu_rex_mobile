import 'package:vocabu_rex_mobile/streak/domain/entities/use_streak_freeze_response_entity.dart';
import 'package:vocabu_rex_mobile/streak/domain/repositories/streak_repository.dart';

class UseStreakFreezeUseCase {
  final StreakRepository repository;

  UseStreakFreezeUseCase({required this.repository});

  Future<UseStreakFreezeResponseEntity> call({String? reason}) {
    return repository.useStreakFreeze(reason: reason);
  }
}
