import 'current_streak_model.dart';
import 'streak_history_entry_model.dart';
import 'streak_statistics_model.dart';

class GetStreakHistoryResponseModel {
  final String userId;
  final CurrentStreakModel currentStreak;
  final int longestStreak;
  final int totalStreaks;
  final List<StreakHistoryEntryModel> history;
  final StreakStatisticsModel statistics;
  final bool success;
  final String? error;

  GetStreakHistoryResponseModel({
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalStreaks,
    required this.history,
    required this.statistics,
    required this.success,
    this.error,
  });

  factory GetStreakHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    return GetStreakHistoryResponseModel(
      userId: json['userId'] as String,
      currentStreak: CurrentStreakModel.fromJson(json['currentStreak']),
      longestStreak: json['longestStreak'] as int,
      totalStreaks: json['totalStreaks'] as int,
      history: (json['history'] as List)
          .map((e) => StreakHistoryEntryModel.fromJson(e))
          .toList(),
      statistics: StreakStatisticsModel.fromJson(json['statistics']),
      success: json['success'] as bool,
      error: json['error'] as String?,
    );
  }
}
