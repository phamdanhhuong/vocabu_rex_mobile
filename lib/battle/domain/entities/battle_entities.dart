class BattleMatchEntity {
  final String matchId;
  final bool isBot;
  final BattlePlayerEntity player1;
  final BattlePlayerEntity player2;
  final int totalRounds;
  final int timePerRound;
  final BattleQuestionEntity? firstRound;

  BattleMatchEntity({
    required this.matchId,
    required this.isBot,
    required this.player1,
    required this.player2,
    required this.totalRounds,
    required this.timePerRound,
    this.firstRound,
  });

  factory BattleMatchEntity.fromJson(Map<String, dynamic> json) {
    return BattleMatchEntity(
      matchId: json['matchId'] ?? '',
      isBot: json['isBot'] ?? false,
      player1: BattlePlayerEntity.fromJson(json['player1'] ?? {}),
      player2: BattlePlayerEntity.fromJson(json['player2'] ?? {}),
      totalRounds: json['totalRounds'] ?? 5,
      timePerRound: json['timePerRound'] ?? 15000,
      firstRound: json['firstRound'] != null
          ? BattleQuestionEntity.fromJson(json['firstRound'])
          : null,
    );
  }
}

class BattlePlayerEntity {
  final String id;
  final String username;
  final String fullName;
  final String? profilePictureUrl;
  final int currentLevel;
  final bool isBot;

  BattlePlayerEntity({
    required this.id,
    required this.username,
    required this.fullName,
    this.profilePictureUrl,
    this.currentLevel = 1,
    this.isBot = false,
  });

  String get displayName => fullName.isNotEmpty ? fullName : username;

  factory BattlePlayerEntity.fromJson(Map<String, dynamic> json) {
    return BattlePlayerEntity(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      profilePictureUrl: json['profilePictureUrl'],
      currentLevel: json['currentLevel'] ?? 1,
      isBot: json['isBot'] ?? false,
    );
  }
}

class BattleQuestionEntity {
  final int roundNumber;
  final String questionType;
  final String prompt;
  final List<String> options;
  final String? audioUrl;
  final int timeLimit;

  BattleQuestionEntity({
    required this.roundNumber,
    required this.questionType,
    required this.prompt,
    required this.options,
    this.audioUrl,
    this.timeLimit = 15000,
  });

  factory BattleQuestionEntity.fromJson(Map<String, dynamic> json) {
    return BattleQuestionEntity(
      roundNumber: json['roundNumber'] ?? 1,
      questionType: json['questionType'] ?? 'multiple_choice',
      prompt: json['prompt'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      audioUrl: json['audioUrl'],
      timeLimit: json['timeLimit'] ?? 15000,
    );
  }
}

class BattleRoundResultEntity {
  final int roundNumber;
  final int player1Points;
  final int player2Points;
  final String correctAnswer;
  final int player1TotalScore;
  final int player2TotalScore;

  BattleRoundResultEntity({
    required this.roundNumber,
    required this.player1Points,
    required this.player2Points,
    required this.correctAnswer,
    required this.player1TotalScore,
    required this.player2TotalScore,
  });

  factory BattleRoundResultEntity.fromJson(Map<String, dynamic> json) {
    final scores = json['scores'] as Map<String, dynamic>? ?? {};
    return BattleRoundResultEntity(
      roundNumber: json['roundNumber'] ?? 0,
      player1Points: json['player1Points'] ?? 0,
      player2Points: json['player2Points'] ?? 0,
      correctAnswer: json['correctAnswer'] ?? '',
      player1TotalScore: scores['player1'] ?? 0,
      player2TotalScore: scores['player2'] ?? 0,
    );
  }
}

class BattleResultEntity {
  final String matchId;
  final String? winnerId;
  final int player1Score;
  final int player2Score;
  final int xpEarned;
  final bool isBot;
  final BattlePlayerEntity? player1;
  final BattlePlayerEntity? player2;

  BattleResultEntity({
    required this.matchId,
    this.winnerId,
    required this.player1Score,
    required this.player2Score,
    required this.xpEarned,
    required this.isBot,
    this.player1,
    this.player2,
  });

  factory BattleResultEntity.fromJson(Map<String, dynamic> json) {
    final xpMap = json['xpAwarded'] as Map<String, dynamic>? ?? {};
    return BattleResultEntity(
      matchId: json['matchId'] ?? '',
      winnerId: json['winnerId'],
      player1Score: json['player1Score'] ?? 0,
      player2Score: json['player2Score'] ?? 0,
      xpEarned: xpMap['player1'] ?? 0,
      isBot: json['isBot'] ?? false,
      player1: json['player1'] != null ? BattlePlayerEntity.fromJson(json['player1']) : null,
      player2: json['player2'] != null ? BattlePlayerEntity.fromJson(json['player2']) : null,
    );
  }
}

class BattleHistoryEntity {
  final String id;
  final BattlePlayerEntity? opponent;
  final int myScore;
  final int opponentScore;
  final String result; // WIN, LOSE, DRAW
  final int xpEarned;
  final bool isBot;
  final DateTime? completedAt;

  BattleHistoryEntity({
    required this.id,
    this.opponent,
    required this.myScore,
    required this.opponentScore,
    required this.result,
    required this.xpEarned,
    required this.isBot,
    this.completedAt,
  });

  factory BattleHistoryEntity.fromJson(Map<String, dynamic> json) {
    return BattleHistoryEntity(
      id: json['id'] ?? '',
      opponent: json['opponent'] != null ? BattlePlayerEntity.fromJson(json['opponent']) : null,
      myScore: json['myScore'] ?? 0,
      opponentScore: json['opponentScore'] ?? 0,
      result: json['result'] ?? 'DRAW',
      xpEarned: json['xpEarned'] ?? 0,
      isBot: json['isBot'] ?? false,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    );
  }
}

class BattleStatsEntity {
  final int totalMatches;
  final int wins;
  final int losses;
  final int draws;
  final int winStreak;
  final int bestWinStreak;

  double get winRate => totalMatches > 0 ? (wins / totalMatches) * 100 : 0;

  BattleStatsEntity({
    required this.totalMatches,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.winStreak,
    required this.bestWinStreak,
  });

  factory BattleStatsEntity.fromJson(Map<String, dynamic> json) {
    return BattleStatsEntity(
      totalMatches: json['totalMatches'] ?? 0,
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      draws: json['draws'] ?? 0,
      winStreak: json['winStreak'] ?? 0,
      bestWinStreak: json['bestWinStreak'] ?? 0,
    );
  }
}
