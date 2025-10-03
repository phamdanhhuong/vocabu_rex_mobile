class UserProfileModel {
  final String id;
  final String email;
  final String profilePictureUrl;
  final String nativeLanguage;
  final DateTime createdAt;
  final DateTime updatedAt;
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

  UserProfileModel({
    required this.id,
    required this.email,
    required this.profilePictureUrl,
    required this.nativeLanguage,
    required this.createdAt,
    required this.updatedAt,
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

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      profilePictureUrl: (json['profilePictureUrl'] as String?) ?? 'https://res.cloudinary.com/diugsirlo/image/upload/v1759473921/download_zsyyia.png',
      nativeLanguage: json['nativeLanguage'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      fullName: json['fullName'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      gender: json['gender'] as String,
      targetLanguage: json['targetLanguage'] as String,
      proficiencyLevel: (json['proficiencyLevel'] as String?) ?? 'BEGINNER',
      learningGoals: List<String>.from(json['learningGoals'] as List? ?? []),
      dailyGoalMinutes: json['dailyGoalMinutes'] as int,
      studyReminder: json['studyReminder'] as String,
      reminderTime: (json['reminderTime'] as String?) ?? '09:00',
      timezone: json['timezone'] as String,
      isEmailVerified: json['isEmailVerified'] as bool,
      isActive: json['isActive'] as bool,
    );
  }
}
