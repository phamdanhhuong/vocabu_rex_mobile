class XPHistoryEntry {
  final String date; // Format: "YYYY-MM-DD"
  final int xp;

  XPHistoryEntry({
    required this.date,
    required this.xp,
  });

  factory XPHistoryEntry.fromJson(Map<String, dynamic> json) {
    return XPHistoryEntry(
      date: json['date'] as String,
      xp: json['xp'] as int? ?? 0,
    );
  }
}

class PublicProfileEntity {
  final String id;
  final String username;
  final String displayName;
  final String avatarUrl;
  final String joinedDate;
  final String countryCode;
  final int followingCount;
  final int followerCount;
  final bool isFollowingMe;
  final bool isFollowedByMe;
  final int streakDays;
  final int totalXp;
  final int currentLevel;
  final bool isInTournament;
  final int top3Count;
  final int englishScore;
  final List<XPHistoryEntry> xpHistory;

  PublicProfileEntity({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    required this.joinedDate,
    required this.countryCode,
    required this.followingCount,
    required this.followerCount,
    this.isFollowingMe = false,
    this.isFollowedByMe = false,
    required this.streakDays,
    required this.totalXp,
    required this.currentLevel,
    required this.isInTournament,
    required this.top3Count,
    this.englishScore = 0,
    this.xpHistory = const [],
  });

  PublicProfileEntity copyWith({
    String? id,
    String? username,
    String? displayName,
    String? avatarUrl,
    String? joinedDate,
    String? countryCode,
    int? followingCount,
    int? followerCount,
    bool? isFollowingMe,
    bool? isFollowedByMe,
    int? streakDays,
    int? totalXp,
    int? currentLevel,
    bool? isInTournament,
    int? top3Count,
    int? englishScore,
    List<XPHistoryEntry>? xpHistory,
  }) {
    return PublicProfileEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      joinedDate: joinedDate ?? this.joinedDate,
      countryCode: countryCode ?? this.countryCode,
      followingCount: followingCount ?? this.followingCount,
      followerCount: followerCount ?? this.followerCount,
      isFollowingMe: isFollowingMe ?? this.isFollowingMe,
      isFollowedByMe: isFollowedByMe ?? this.isFollowedByMe,
      streakDays: streakDays ?? this.streakDays,
      totalXp: totalXp ?? this.totalXp,
      currentLevel: currentLevel ?? this.currentLevel,
      isInTournament: isInTournament ?? this.isInTournament,
      top3Count: top3Count ?? this.top3Count,
      englishScore: englishScore ?? this.englishScore,
      xpHistory: xpHistory ?? this.xpHistory,
    );
  }
}
