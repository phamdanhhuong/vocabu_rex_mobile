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
