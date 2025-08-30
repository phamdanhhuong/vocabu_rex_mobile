import 'package:vocabu_rex_mobile/home/data/models/user_profile_model.dart';

class UserProfileEntity {
  final String id;
  final String email;
  final String name;
  final String profilePictureUrl;
  final String nativeLanguage;

  UserProfileEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.profilePictureUrl,
    required this.nativeLanguage,
  });

  factory UserProfileEntity.fromModel(UserProfileModel model) {
    return UserProfileEntity(
      id: model.id,
      email: model.email,
      name: model.name,
      profilePictureUrl: model.profilePictureUrl,
      nativeLanguage: model.nativeLanguage,
    );
  }

  UserProfileEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? profilePictureUrl,
    String? nativeLanguage,
  }) {
    return UserProfileEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
    );
  }
}
