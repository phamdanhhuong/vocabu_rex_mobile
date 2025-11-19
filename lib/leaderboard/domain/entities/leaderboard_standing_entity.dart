class LeaderboardStandingEntity {
  final int rank;
  final String userId;
  final String? username;
  final String? fullName;
  final String? profilePictureUrl;
  final int weeklyXp;
  final bool isCurrentUser;
  final bool isPromoted;
  final bool isDemoted;

  LeaderboardStandingEntity({
    required this.rank,
    required this.userId,
    this.username,
    this.fullName,
    this.profilePictureUrl,
    required this.weeklyXp,
    this.isCurrentUser = false,
    this.isPromoted = false,
    this.isDemoted = false,
  });

  factory LeaderboardStandingEntity.fromJson(Map<String, dynamic> json) {
    return LeaderboardStandingEntity(
      rank: json['rank'] as int,
      userId: json['userId'] as String,
      username: json['username'] as String?,
      fullName: json['fullName'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      weeklyXp: json['weeklyXp'] as int,
      isCurrentUser: json['isCurrentUser'] as bool? ?? false,
      isPromoted: json['isPromoted'] as bool? ?? false,
      isDemoted: json['isDemoted'] as bool? ?? false,
    );
  }
}
