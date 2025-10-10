class ProfileEntity {
  final String id;
  final String username;
  final String displayName;
  final String avatarUrl;
  final String joinedDate;
  final String countryCode;
  final int followingCount;
  final int followerCount;
  final int streakDays;
  final int totalExp;
  final bool isInTournament;
  final int top3Count;

  ProfileEntity({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    required this.joinedDate,
    required this.countryCode,
    required this.followingCount,
    required this.followerCount,
    required this.streakDays,
    required this.totalExp,
    required this.isInTournament,
    required this.top3Count,
  });
static ProfileEntity fromModel(dynamic model) {
    return ProfileEntity(
      id: model.id,
      username: model.username,
      displayName: model.displayName,
      avatarUrl: model.avatarUrl,
      joinedDate: model.joinedDate,
      countryCode: model.countryCode,
      followingCount: model.followingCount,
      followerCount: model.followerCount,
      streakDays: model.streakDays,
      totalExp: model.totalExp,
      isInTournament: model.isInTournament,
      top3Count: model.top3Count,
    );
  }

  ProfileEntity copyWith({
    String? id,
    String? username,
    String? displayName,
    String? avatarUrl,
    String? joinedDate,
    String? countryCode,
    int? followingCount,
    int? followerCount,
    int? streakDays,
    int? totalExp,
    bool? isInTournament,
    int? top3Count,
  }) {
    return ProfileEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      joinedDate: joinedDate ?? this.joinedDate,
      countryCode: countryCode ?? this.countryCode,
      followingCount: followingCount ?? this.followingCount,
      followerCount: followerCount ?? this.followerCount,
      streakDays: streakDays ?? this.streakDays,
      totalExp: totalExp ?? this.totalExp,
      isInTournament: isInTournament ?? this.isInTournament,
      top3Count: top3Count ?? this.top3Count,
    );
  }
}
