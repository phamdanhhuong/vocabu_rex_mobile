class DailyActivityPoint {
  final String date;
  final int xpEarned;
  final int lessonsCount;
  final int exerciseCount;

  DailyActivityPoint({
    required this.date,
    required this.xpEarned,
    required this.lessonsCount,
    required this.exerciseCount,
  });

  factory DailyActivityPoint.fromJson(Map<String, dynamic> json) {
    return DailyActivityPoint(
      date: json['date'] ?? '',
      xpEarned: json['xpEarned'] ?? 0,
      lessonsCount: json['lessonsCount'] ?? 0,
      exerciseCount: json['exerciseCount'] ?? 0,
    );
  }
}

class ExerciseAccuracy {
  final String exerciseType;
  final int totalAttempts;
  final int correctCount;
  final int incorrectCount;
  final int accuracyPercent;

  ExerciseAccuracy({
    required this.exerciseType,
    required this.totalAttempts,
    required this.correctCount,
    required this.incorrectCount,
    required this.accuracyPercent,
  });

  factory ExerciseAccuracy.fromJson(Map<String, dynamic> json) {
    return ExerciseAccuracy(
      exerciseType: json['exerciseType'] ?? '',
      totalAttempts: json['totalAttempts'] ?? 0,
      correctCount: json['correctCount'] ?? 0,
      incorrectCount: json['incorrectCount'] ?? 0,
      accuracyPercent: json['accuracyPercent'] ?? 0,
    );
  }
}

class WordMasteryDistribution {
  final int masteryLevel;
  final int count;

  WordMasteryDistribution({
    required this.masteryLevel,
    required this.count,
  });

  factory WordMasteryDistribution.fromJson(Map<String, dynamic> json) {
    return WordMasteryDistribution(
      masteryLevel: json['masteryLevel'] ?? 0,
      count: json['count'] ?? 0,
    );
  }
}

class StreakSummary {
  final int currentStreak;
  final int longestStreak;
  final int totalStudyDays;

  StreakSummary({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalStudyDays,
  });

  factory StreakSummary.fromJson(Map<String, dynamic> json) {
    return StreakSummary(
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      totalStudyDays: json['totalStudyDays'] ?? 0,
    );
  }
}

class BattleSummary {
  final int totalMatches;
  final int wins;
  final int losses;
  final int draws;
  final int winRate;

  BattleSummary({
    required this.totalMatches,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.winRate,
  });

  factory BattleSummary.fromJson(Map<String, dynamic> json) {
    return BattleSummary(
      totalMatches: json['totalMatches'] ?? 0,
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      draws: json['draws'] ?? 0,
      winRate: json['winRate'] ?? 0,
    );
  }
}

class AnalyticsDashboardModel {
  final List<DailyActivityPoint> dailyActivities;
  final int totalXp;
  final int currentLevel;
  final List<ExerciseAccuracy> exerciseAccuracy;
  final List<WordMasteryDistribution> wordMastery;
  final int grammarMasteryCount;
  final StreakSummary streak;
  final BattleSummary battle;
  final int totalWordsLearned;
  final int totalExercisesCompleted;

  AnalyticsDashboardModel({
    required this.dailyActivities,
    required this.totalXp,
    required this.currentLevel,
    required this.exerciseAccuracy,
    required this.wordMastery,
    required this.grammarMasteryCount,
    required this.streak,
    required this.battle,
    required this.totalWordsLearned,
    required this.totalExercisesCompleted,
  });

  factory AnalyticsDashboardModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsDashboardModel(
      dailyActivities: (json['dailyActivities'] as List? ?? [])
          .map((e) => DailyActivityPoint.fromJson(e))
          .toList(),
      totalXp: json['totalXp'] ?? 0,
      currentLevel: json['currentLevel'] ?? 1,
      exerciseAccuracy: (json['exerciseAccuracy'] as List? ?? [])
          .map((e) => ExerciseAccuracy.fromJson(e))
          .toList(),
      wordMastery: (json['wordMastery'] as List? ?? [])
          .map((e) => WordMasteryDistribution.fromJson(e))
          .toList(),
      grammarMasteryCount: json['grammarMasteryCount'] ?? 0,
      streak: StreakSummary.fromJson(json['streak'] ?? {}),
      battle: BattleSummary.fromJson(json['battle'] ?? {}),
      totalWordsLearned: json['totalWordsLearned'] ?? 0,
      totalExercisesCompleted: json['totalExercisesCompleted'] ?? 0,
    );
  }
}
