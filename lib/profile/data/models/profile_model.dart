
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
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return ProfileModel(
      id: data['id'] as String,
      username: data['email'] as String, // dùng email làm username
      displayName: data['fullName'] as String? ?? '',
      avatarUrl: data['profilePictureUrl'] as String? ?? '',
      joinedDate: data['createdAt'] as String? ?? '',
      countryCode: data['countryCode'] as String? ?? '',
      followingCount: data['followingCount'] as int? ?? 0,
      followerCount: data['followerCount'] as int? ?? 0,
      streakDays: data['streakDays'] as int? ?? 0,
      totalExp: data['totalExp'] as int? ?? 0,
      isInTournament: data['isInTournament'] as bool? ?? false,
      top3Count: data['top3Count'] as int? ?? 0,
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
    };
  }
}
