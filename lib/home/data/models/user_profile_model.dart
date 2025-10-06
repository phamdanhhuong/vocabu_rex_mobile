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
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      profilePictureUrl:
          json['profilePictureUrl'] as String? ??
          'https://res.cloudinary.com/diugsirlo/image/upload/v1759473921/download_zsyyia.png',
      nativeLanguage: json['nativeLanguage'] as String? ?? 'vi',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      fullName: json['fullName'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : DateTime(2000, 1, 1),
      gender: json['gender'] as String? ?? 'other',
      targetLanguage: json['targetLanguage'] as String? ?? 'en',
      proficiencyLevel: json['proficiencyLevel'] as String? ?? 'beginner',
      learningGoals: json['learningGoals'] != null
          ? List<String>.from(json['learningGoals'] as List)
          : <String>[],
      dailyGoalMinutes: json['dailyGoalMinutes'] as int? ?? 30,
      studyReminder: json['studyReminder'] as String? ?? 'daily',
      reminderTime: json['reminderTime'] as String? ?? '09:00',
      timezone: json['timezone'] as String? ?? 'Asia/Ho_Chi_Minh',
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
