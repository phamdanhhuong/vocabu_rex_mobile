import 'package:vocabu_rex_mobile/profile/domain/entities/public_profile_entity.dart';

class XPHistoryModel {
  final String date;
  final int xp;

  XPHistoryModel({
    required this.date,
    required this.xp,
  });

  factory XPHistoryModel.fromJson(Map<String, dynamic> json) {
    return XPHistoryModel(
      date: json['date'] as String,
      xp: json['xp'] as int? ?? 0,
    );
  }

  XPHistoryEntry toEntity() {
    return XPHistoryEntry(date: date, xp: xp);
  }
}

class PublicProfileModel {
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
  final List<XPHistoryModel> xpHistory;

  PublicProfileModel({
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

  factory PublicProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    
    List<XPHistoryModel> xpHistoryList = [];
    if (data['xpHistory'] != null) {
      xpHistoryList = (data['xpHistory'] as List)
          .map((item) => XPHistoryModel.fromJson(item))
          .toList();
    }

    return PublicProfileModel(
      id: data['id'] as String,
      username: data['username'] as String? ?? '',
      displayName: data['displayName'] as String? ?? 'User',
      avatarUrl: data['avatarUrl'] as String? ?? '',
      joinedDate: data['joinedDate'] as String? ?? '',
      countryCode: data['countryCode'] as String? ?? 'VN',
      followingCount: data['followingCount'] as int? ?? 0,
      followerCount: data['followerCount'] as int? ?? 0,
      isFollowingMe: data['isFollowingMe'] as bool? ?? false,
      isFollowedByMe: data['isFollowedByMe'] as bool? ?? false,
      streakDays: data['streakDays'] as int? ?? 0,
      totalXp: data['totalXp'] as int? ?? 0,
      currentLevel: data['currentLevel'] as int? ?? 1,
      isInTournament: data['isInTournament'] as bool? ?? false,
      top3Count: data['top3Count'] as int? ?? 0,
      englishScore: data['englishScore'] as int? ?? 0,
      xpHistory: xpHistoryList,
    );
  }

  PublicProfileEntity toEntity() {
    return PublicProfileEntity(
      id: id,
      username: username,
      displayName: displayName,
      avatarUrl: avatarUrl,
      joinedDate: joinedDate,
      countryCode: countryCode,
      followingCount: followingCount,
      followerCount: followerCount,
      isFollowingMe: isFollowingMe,
      isFollowedByMe: isFollowedByMe,
      streakDays: streakDays,
      totalXp: totalXp,
      currentLevel: currentLevel,
      isInTournament: isInTournament,
      top3Count: top3Count,
      englishScore: englishScore,
      xpHistory: xpHistory.map((h) => h.toEntity()).toList(),
    );
  }
}
