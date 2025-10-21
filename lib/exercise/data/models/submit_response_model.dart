class SubmitResponseModel {
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
  final Map<String, dynamic> bonuses;
  final bool isPerfect;
  final List<Map<String, dynamic>> rewards;
  final String? skillProgressMessage;

  SubmitResponseModel({
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

  factory SubmitResponseModel.fromJson(Map<String, dynamic> json) {
    return SubmitResponseModel(
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
      bonuses: Map<String, dynamic>.from(json['bonuses'] ?? {}),
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

  SubmitResponseModel copyWith({
    String? lessonId,
    String? skillId,
    int? totalExercises,
    int? correctExercises,
    double? accuracy,
    int? wordMasteriesUpdated,
    int? grammarMasteriesUpdated,
    bool? isLessonSuccessful,
    String? message,
    int? xpEarned,
    Map<String, dynamic>? bonuses,
    bool? isPerfect,
    List<Map<String, dynamic>>? rewards,
    String? skillProgressMessage,
  }) {
    return SubmitResponseModel(
      lessonId: lessonId ?? this.lessonId,
      skillId: skillId ?? this.skillId,
      totalExercises: totalExercises ?? this.totalExercises,
      correctExercises: correctExercises ?? this.correctExercises,
      accuracy: accuracy ?? this.accuracy,
      wordMasteriesUpdated: wordMasteriesUpdated ?? this.wordMasteriesUpdated,
      grammarMasteriesUpdated:
          grammarMasteriesUpdated ?? this.grammarMasteriesUpdated,
      isLessonSuccessful: isLessonSuccessful ?? this.isLessonSuccessful,
      message: message ?? this.message,
      xpEarned: xpEarned ?? this.xpEarned,
      bonuses: bonuses ?? this.bonuses,
      isPerfect: isPerfect ?? this.isPerfect,
      rewards: rewards ?? this.rewards,
      skillProgressMessage: skillProgressMessage ?? this.skillProgressMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubmitResponseModel &&
        other.lessonId == lessonId &&
        other.skillId == skillId &&
        other.totalExercises == totalExercises &&
        other.correctExercises == correctExercises &&
        other.accuracy == accuracy &&
        other.wordMasteriesUpdated == wordMasteriesUpdated &&
        other.grammarMasteriesUpdated == grammarMasteriesUpdated &&
    other.isLessonSuccessful == isLessonSuccessful &&
    other.message == message &&
    other.xpEarned == xpEarned;
  }

  @override
  int get hashCode {
    return lessonId.hashCode ^
        skillId.hashCode ^
        totalExercises.hashCode ^
        correctExercises.hashCode ^
        accuracy.hashCode ^
        wordMasteriesUpdated.hashCode ^
        grammarMasteriesUpdated.hashCode ^
        isLessonSuccessful.hashCode ^
    message.hashCode ^ xpEarned.hashCode;
  }

  @override
  String toString() {
    return 'SubmitResponseModel('
        'lessonId: $lessonId, '
        'skillId: $skillId, '
        'totalExercises: $totalExercises, '
        'correctExercises: $correctExercises, '
        'accuracy: $accuracy, '
        'wordMasteriesUpdated: $wordMasteriesUpdated, '
        'grammarMasteriesUpdated: $grammarMasteriesUpdated, '
        'isLessonSuccessful: $isLessonSuccessful, '
        'message: $message'
        ')';
  }

  // Computed properties for convenience
  double get accuracyPercentage => accuracy * 100;
  bool get isPerfectScore => accuracy == 1.0;
  bool get hasWordMasteriesUpdate => wordMasteriesUpdated > 0;
  bool get hasGrammarMasteriesUpdate => grammarMasteriesUpdated > 0;
  int get totalMasteriesUpdated =>
      wordMasteriesUpdated + grammarMasteriesUpdated;

  int get xp => xpEarned;
}
