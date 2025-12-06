enum DayStatus {
  active,
  frozen,
  missed,
  noStreak,
  future,
}

class CalendarDayModel {
  final String date;
  final DayStatus status;
  final int streakCount;
  final bool isStreakStart;
  final bool isStreakEnd;
  final bool freezeUsed;

  CalendarDayModel({
    required this.date,
    required this.status,
    required this.streakCount,
    required this.isStreakStart,
    required this.isStreakEnd,
    required this.freezeUsed,
  });

  factory CalendarDayModel.fromJson(Map<String, dynamic> json) {
    return CalendarDayModel(
      date: json['date'] as String,
      status: _parseStatus(json['status'] as String),
      streakCount: json['streakCount'] as int,
      isStreakStart: json['isStreakStart'] as bool,
      isStreakEnd: json['isStreakEnd'] as bool,
      freezeUsed: json['freezeUsed'] as bool,
    );
  }

  static DayStatus _parseStatus(String status) {
    switch (status) {
      case 'active':
        return DayStatus.active;
      case 'frozen':
        return DayStatus.frozen;
      case 'missed':
        return DayStatus.missed;
      case 'no_streak':
        return DayStatus.noStreak;
      case 'future':
        return DayStatus.future;
      default:
        return DayStatus.noStreak;
    }
  }
}
