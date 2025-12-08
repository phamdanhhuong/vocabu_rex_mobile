import 'package:vocabu_rex_mobile/profile/domain/entities/public_profile_entity.dart';

class ProfileModel {
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
  final String? currentLeagueTier;
  final int skillPosition;
  final List<XPHistoryEntry> xpHistory;

  ProfileModel({
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
    this.currentLeagueTier,
    this.skillPosition = 1,
    this.xpHistory = const [],
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    
    // Parse xpHistory if available
    List<XPHistoryEntry> xpHistoryList = [];
    if (data['xpHistory'] != null) {
      xpHistoryList = (data['xpHistory'] as List)
          .map((item) => XPHistoryEntry.fromJson(item))
          .toList();
    }
    
    return ProfileModel(
      id: data['id'] as String,
      // Backend giờ trả về username riêng, không dùng email
      username: data['username'] as String? ?? data['email'] as String? ?? '',
      // Backend trả displayName hoặc fallback về name
      displayName: data['displayName'] as String? ?? data['name'] as String? ?? 'User',
      // Backend trả avatarUrl (mapped từ profilePictureUrl)
      avatarUrl: data['avatarUrl'] as String? ?? data['profilePictureUrl'] as String? ?? '',
      // Backend trả joinedDate đã format sẵn (DD/MM/YYYY)
      joinedDate: data['joinedDate'] as String? ?? '',
      countryCode: data['countryCode'] as String? ?? 'VN',
      followingCount: data['followingCount'] as int? ?? 0,
      followerCount: data['followerCount'] as int? ?? 0,
      // Backend trả streakDays (mapped từ totalStreak)
      streakDays: data['streakDays'] as int? ?? data['totalStreak'] as int? ?? 0,
      // Backend trả totalExp (mapped từ totalXp)
      totalExp: data['totalExp'] as int? ?? data['totalXp'] as int? ?? 0,
      isInTournament: data['isInTournament'] as bool? ?? false,
      top3Count: data['top3Count'] as int? ?? 0,
      currentLeagueTier: data['currentLeagueTier'] as String?,
      skillPosition: data['skillPosition'] as int? ?? 1,
      xpHistory: xpHistoryList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'joinedDate': joinedDate,
      'countryCode': countryCode,
      'followingCount': followingCount,
      'followerCount': followerCount,
      'streakDays': streakDays,
      'totalExp': totalExp,
      'isInTournament': isInTournament,
      'top3Count': top3Count,
      'currentLeagueTier': currentLeagueTier,
      'skillPosition': skillPosition,
      'top3Count': top3Count,
      'xpHistory': xpHistory.map((e) => {'date': e.date, 'xp': e.xp}).toList(),
    };
  }
}
