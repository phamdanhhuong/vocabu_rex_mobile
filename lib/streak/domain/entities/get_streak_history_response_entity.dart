import 'current_streak_entity.dart';
import 'streak_history_entry_entity.dart';
import 'streak_statistics_entity.dart';

class GetStreakHistoryResponseEntity {
  final String userId;
  final CurrentStreakEntity currentStreak;
  final int longestStreak;
  final int totalStreaks;
  final List<StreakHistoryEntryEntity> history;
  final StreakStatisticsEntity statistics;
  final bool success;
  final String? error;

  GetStreakHistoryResponseEntity({
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalStreaks,
    required this.history,
    required this.statistics,
    required this.success,
    this.error,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'currentStreak': currentStreak.toJson(),
      'longestStreak': longestStreak,
      'totalStreaks': totalStreaks,
      'history': history.map((e) => e.toJson()).toList(),
      'statistics': statistics.toJson(),
      'success': success,
      'error': error,
    };
  }
}
