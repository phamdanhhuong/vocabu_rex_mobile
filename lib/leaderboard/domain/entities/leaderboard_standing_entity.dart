class LeaderboardStandingEntity {
  final int rank;
  final String userId;
  final String? username;
  final String? fullName;
  final String? profilePictureUrl;
  final String? equippedFrameId;
  final String? equippedBackgroundId;
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
    this.equippedFrameId,
    this.equippedBackgroundId,
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
      equippedFrameId: json['equippedFrameId'] as String?,
      equippedBackgroundId: json['equippedBackgroundId'] as String?,
      weeklyXp: json['weeklyXp'] as int? ?? 0,
      isCurrentUser: json['isCurrentUser'] as bool? ?? false,
      isPromoted: json['isPromoted'] as bool? ?? false,
      isDemoted: json['isDemoted'] as bool? ?? false,
    );
  }
}
