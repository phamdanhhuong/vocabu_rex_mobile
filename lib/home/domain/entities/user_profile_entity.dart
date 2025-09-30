import 'package:vocabu_rex_mobile/home/data/models/user_profile_model.dart';

class UserProfileEntity {
  final String id;
  final String email;
  final String profilePictureUrl;
  final String nativeLanguage;
  final String fullName;
  final DateTime dateOfBirth;
  final String gender;
  final String targetLanguage;
  final String proficiencyLevel;
  final List<String> learningGoals;
  final int dailyGoalMinutes;
  final String studyReminder;
  final String reminderTime;
  final String timezone;
  final bool isEmailVerified;
  final bool isActive;

  UserProfileEntity({
    required this.id,
    required this.email,
    required this.profilePictureUrl,
    required this.nativeLanguage,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    required this.targetLanguage,
    required this.proficiencyLevel,
    required this.learningGoals,
    required this.dailyGoalMinutes,
    required this.studyReminder,
    required this.reminderTime,
    required this.timezone,
    required this.isEmailVerified,
    required this.isActive,
  });

  factory UserProfileEntity.fromModel(UserProfileModel model) {
    return UserProfileEntity(
      id: model.id,
      email: model.email,
      profilePictureUrl: model.profilePictureUrl,
      nativeLanguage: model.nativeLanguage,
      fullName: model.fullName,
      dateOfBirth: model.dateOfBirth,
      gender: model.gender,
      targetLanguage: model.targetLanguage,
      proficiencyLevel: model.proficiencyLevel,
      learningGoals: model.learningGoals,
      dailyGoalMinutes: model.dailyGoalMinutes,
      studyReminder: model.studyReminder,
      reminderTime: model.reminderTime,
      timezone: model.timezone,
      isEmailVerified: model.isEmailVerified,
      isActive: model.isActive,
    );
  }

  UserProfileEntity copyWith({
    String? id,
    String? email,
    String? profilePictureUrl,
    String? nativeLanguage,
    String? fullName,
    DateTime? dateOfBirth,
    String? gender,
    String? targetLanguage,
    String? proficiencyLevel,
    List<String>? learningGoals,
    int? dailyGoalMinutes,
    String? studyReminder,
    String? reminderTime,
    String? timezone,
    bool? isEmailVerified,
    bool? isActive,
  }) {
    return UserProfileEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      proficiencyLevel: proficiencyLevel ?? this.proficiencyLevel,
      learningGoals: learningGoals ?? this.learningGoals,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      studyReminder: studyReminder ?? this.studyReminder,
      reminderTime: reminderTime ?? this.reminderTime,
      timezone: timezone ?? this.timezone,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isActive: isActive ?? this.isActive,
    );
  }
}
