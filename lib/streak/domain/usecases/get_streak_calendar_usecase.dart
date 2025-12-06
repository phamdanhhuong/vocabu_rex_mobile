import '../entities/get_streak_calendar_response_entity.dart';
import '../repositories/streak_repository.dart';

class GetStreakCalendarUseCase {
  final StreakRepository repository;

  GetStreakCalendarUseCase(this.repository);

  Future<GetStreakCalendarResponseEntity> call({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await repository.getStreakCalendar(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
