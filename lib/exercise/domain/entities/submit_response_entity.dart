class SubmitResponseEntity {
  final String lessonId;
  final String skillId;
  final int totalExercises;
  final int correctExercises;
  final double accuracy;
  final int wordMasteriesUpdated;
  final int grammarMasteriesUpdated;
  final bool isLessonSuccessful;
  final String message;
  final int xpEarned;
  final Map<String, int> bonuses; // baseXP, bonusXP, perfectBonusXP
  final bool isPerfect;
  final List<Map<String, dynamic>> rewards;
  final String? skillProgressMessage;

  SubmitResponseEntity({
    required this.lessonId,
    required this.skillId,
    required this.totalExercises,
    required this.correctExercises,
    required this.accuracy,
    required this.wordMasteriesUpdated,
    required this.grammarMasteriesUpdated,
    required this.isLessonSuccessful,
    required this.message,
    required this.xpEarned,
    required this.bonuses,
    required this.isPerfect,
    required this.rewards,
    this.skillProgressMessage,
  });

  factory SubmitResponseEntity.fromJson(Map<String, dynamic> json) {
    return SubmitResponseEntity(
      lessonId: json['lessonId'] as String,
      skillId: json['skillId'] as String,
      totalExercises: json['totalExercises'] as int,
      correctExercises: json['correctExercises'] as int,
      accuracy: (json['accuracy'] as num).toDouble(),
      wordMasteriesUpdated: json['wordMasteriesUpdated'] as int,
      grammarMasteriesUpdated: json['grammarMasteriesUpdated'] as int,
      isLessonSuccessful: json['isLessonSuccessful'] as bool,
      message: json['message'] as String,
      xpEarned: (json['xpEarned'] ?? 0) as int,
      bonuses: Map<String, int>.from(json['bonuses'] ?? {}),
      isPerfect: json['isPerfect'] ?? false,
      rewards: (json['rewards'] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [],
      skillProgressMessage: json['skillProgressMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'skillId': skillId,
      'totalExercises': totalExercises,
      'correctExercises': correctExercises,
      'accuracy': accuracy,
      'wordMasteriesUpdated': wordMasteriesUpdated,
      'grammarMasteriesUpdated': grammarMasteriesUpdated,
      'isLessonSuccessful': isLessonSuccessful,
      'message': message,
      'xpEarned': xpEarned,
      'bonuses': bonuses,
      'isPerfect': isPerfect,
      'rewards': rewards,
      'skillProgressMessage': skillProgressMessage,
    };
  }
}
