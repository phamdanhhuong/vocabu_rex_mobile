import 'calendar_day_model.dart';
import 'calendar_summary_model.dart';

class GetStreakCalendarResponseModel {
  final String userId;
  final String startDate;
  final String endDate;
  final List<CalendarDayModel> days;
  final CalendarSummaryModel summary;
  final bool success;
  final String? error;

  GetStreakCalendarResponseModel({
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.summary,
    required this.success,
    this.error,
  });

  factory GetStreakCalendarResponseModel.fromJson(Map<String, dynamic> json) {
    return GetStreakCalendarResponseModel(
      userId: json['userId'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      days: (json['days'] as List<dynamic>)
          .map((e) => CalendarDayModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary: CalendarSummaryModel.fromJson(json['summary'] as Map<String, dynamic>),
      success: json['success'] as bool,
      error: json['error'] as String?,
    );
  }
}
