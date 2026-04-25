class BattleMatchEntity {
  final String matchId;
  final bool isBot;
  final BattlePlayerEntity player1;
  final BattlePlayerEntity player2;
  final int totalRounds;
  final int timePerRound;
  final int maxHp;
  final BattleQuestionEntity? firstRound;

  BattleMatchEntity({
    required this.matchId,
    required this.isBot,
    required this.player1,
    required this.player2,
    required this.totalRounds,
    required this.timePerRound,
    this.maxHp = 1000,
    this.firstRound,
  });

  factory BattleMatchEntity.fromJson(Map<String, dynamic> json) {
    return BattleMatchEntity(
      matchId: json['matchId'] ?? '',
      isBot: json['isBot'] ?? false,
      player1: BattlePlayerEntity.fromJson(json['player1'] ?? {}),
      player2: BattlePlayerEntity.fromJson(json['player2'] ?? {}),
      totalRounds: json['totalRounds'] ?? 7,
      timePerRound: json['timePerRound'] ?? 15000,
      maxHp: json['maxHp'] ?? 1000,
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
  final String exerciseType;
  final String? exerciseId;
  final String prompt;
  final List<String> options;
  final String? audioUrl;
  final int timeLimit;
  final Map<String, dynamic>? rawMeta;

  BattleQuestionEntity({
    required this.roundNumber,
    required this.questionType,
    required this.prompt,
    required this.options,
    this.exerciseType = 'multiple_choice',
    this.exerciseId,
    this.audioUrl,
    this.timeLimit = 15000,
    this.rawMeta,
  });

  factory BattleQuestionEntity.fromJson(Map<String, dynamic> json) {
    return BattleQuestionEntity(
      roundNumber: json['roundNumber'] ?? 1,
      questionType: json['questionType'] ?? 'multiple_choice',
      exerciseType: json['exerciseType'] ?? json['questionType'] ?? 'multiple_choice',
      exerciseId: json['exerciseId'],
      prompt: json['prompt'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      audioUrl: json['audioUrl'],
      timeLimit: json['timeLimit'] ?? 15000,
      rawMeta: json['rawMeta'] != null ? Map<String, dynamic>.from(json['rawMeta']) : null,
    );
  }
}

// ─── HP Combat Events ───

class BattleDamageEvent {
  final String attackerId;
  final String? targetId;
  final int damage;
  final int selfDamage;
  final bool isCorrect;
  final String? correctAnswer;
  final int roundNumber;
  final int player1Hp;
  final int player2Hp;

  BattleDamageEvent({
    required this.attackerId,
    this.targetId,
    required this.damage,
    required this.selfDamage,
    required this.isCorrect,
    this.correctAnswer,
    required this.roundNumber,
    required this.player1Hp,
    required this.player2Hp,
  });

  factory BattleDamageEvent.fromJson(Map<String, dynamic> json) {
    return BattleDamageEvent(
      attackerId: json['attackerId'] ?? '',
      targetId: json['targetId'],
      damage: json['damage'] ?? 0,
      selfDamage: json['selfDamage'] ?? 0,
      isCorrect: json['isCorrect'] ?? false,
      correctAnswer: json['correctAnswer'],
      roundNumber: json['roundNumber'] ?? 0,
      player1Hp: json['player1Hp'] ?? 0,
      player2Hp: json['player2Hp'] ?? 0,
    );
  }
}

class BattleResultEntity {
  final String matchId;
  final String? winnerId;
  final int player1Hp;
  final int player2Hp;
  final bool isKO;
  final int xpEarned;
  final bool isBot;
  final BattlePlayerEntity? player1;
  final BattlePlayerEntity? player2;

  BattleResultEntity({
    required this.matchId,
    this.winnerId,
    required this.player1Hp,
    required this.player2Hp,
    required this.isKO,
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
      player1Hp: json['player1Hp'] ?? 0,
      player2Hp: json['player2Hp'] ?? 0,
      isKO: json['isKO'] ?? false,
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
  final String result;
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
