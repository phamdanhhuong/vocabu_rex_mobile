class UserModel {
  final String id;
  final String username;
  final String displayName;
  final String avatarUrl;
  final String? equippedFrameId;
  final String? equippedBackgroundId;
  final bool isFollowing;
  final String? subtext;

  UserModel({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    this.equippedFrameId,
    this.equippedBackgroundId,
    this.isFollowing = false,
    this.subtext,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String? ?? '',
      displayName:
          json['displayName'] as String? ?? json['name'] as String? ?? 'User',
      avatarUrl:
          json['avatarUrl'] as String? ??
          json['profilePictureUrl'] as String? ??
          '',
      equippedFrameId: json['equippedFrameId'] as String?,
      equippedBackgroundId: json['equippedBackgroundId'] as String?,
      isFollowing: json['isFollowing'] as bool? ?? false,
      subtext: json['subtext'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'equippedFrameId': equippedFrameId,
      'equippedBackgroundId': equippedBackgroundId,
      'isFollowing': isFollowing,
      'subtext': subtext,
    };
  }
}
