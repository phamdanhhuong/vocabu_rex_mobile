class UserEntity {
  final String id;
  final String username;
  final String displayName;
  final String avatarUrl;
  final bool isFollowing;
  final String? subtext; // Cho suggestions: "ok ok đã theo dõi", "Các bạn có thể quen nhau"

  UserEntity({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    this.isFollowing = false,
    this.subtext,
  });

  static UserEntity fromModel(dynamic model) {
    return UserEntity(
      id: model.id,
      username: model.username,
      displayName: model.displayName,
      avatarUrl: model.avatarUrl,
      isFollowing: model.isFollowing,
      subtext: model.subtext,
    );
  }

  UserEntity copyWith({
    String? id,
    String? username,
    String? displayName,
    String? avatarUrl,
    bool? isFollowing,
    String? subtext,
  }) {
    return UserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isFollowing: isFollowing ?? this.isFollowing,
      subtext: subtext ?? this.subtext,
    );
  }
}
