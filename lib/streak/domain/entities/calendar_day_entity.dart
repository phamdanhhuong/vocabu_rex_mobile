import '../../data/models/calendar_day_model.dart' show DayStatus;

class CalendarDayEntity {
  final DateTime date;
  final DayStatus status;
  final int streakCount;
  final bool isStreakStart;
  final bool isStreakEnd;
  final bool freezeUsed;

  CalendarDayEntity({
    required this.date,
    required this.status,
    required this.streakCount,
    required this.isStreakStart,
    required this.isStreakEnd,
    required this.freezeUsed,
  });
}
