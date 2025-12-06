abstract class StreakEvent {}

class GetStreakHistoryEvent extends StreakEvent {
  final int? limit;
  final bool? includeCurrentStreak;
  GetStreakHistoryEvent({this.limit, this.includeCurrentStreak});
}

class UseStreakFreezeEvent extends StreakEvent {
  final String? reason;
  UseStreakFreezeEvent({this.reason});
}

class GetStreakCalendarEvent extends StreakEvent {
  final DateTime startDate;
  final DateTime endDate;
  GetStreakCalendarEvent({required this.startDate, required this.endDate});
}
