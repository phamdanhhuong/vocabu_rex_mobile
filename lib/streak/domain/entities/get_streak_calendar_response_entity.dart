import 'calendar_day_entity.dart';
import 'calendar_summary_entity.dart';

class GetStreakCalendarResponseEntity {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final List<CalendarDayEntity> days;
  final CalendarSummaryEntity summary;
  final bool success;
  final String? error;

  GetStreakCalendarResponseEntity({
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.summary,
    required this.success,
    this.error,
  });
}
