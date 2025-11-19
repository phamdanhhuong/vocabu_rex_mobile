import 'vowel_progress.dart';
import 'consonant_progress.dart';

class PronunciationProgress {
  final List<VowelProgress> vowelProgress;
  final List<ConsonantProgress> consonantProgress;
  final int totalVowels;
  final int totalConsonants;
  final int overallProgressPercentage;

  const PronunciationProgress({
    required this.vowelProgress,
    required this.consonantProgress,
    required this.totalVowels,
    required this.totalConsonants,
    required this.overallProgressPercentage,
  });

  factory PronunciationProgress.fromModel(dynamic model) {
    return PronunciationProgress(
      vowelProgress: (model.vowelProgress as List)
          .map((vowelModel) => VowelProgress.fromModel(vowelModel))
          .toList(),
      consonantProgress: (model.consonantProgress as List)
          .map((consonantModel) => ConsonantProgress.fromModel(consonantModel))
          .toList(),
      totalVowels: model.totalVowels,
      totalConsonants: model.totalConsonants,
      overallProgressPercentage: model.overallProgressPercentage,
    );
  }

  PronunciationProgress copyWith({
    List<VowelProgress>? vowelProgress,
    List<ConsonantProgress>? consonantProgress,
    int? totalVowels,
    int? totalConsonants,
    int? overallProgressPercentage,
  }) {
    return PronunciationProgress(
      vowelProgress: vowelProgress ?? this.vowelProgress,
      consonantProgress: consonantProgress ?? this.consonantProgress,
      totalVowels: totalVowels ?? this.totalVowels,
      totalConsonants: totalConsonants ?? this.totalConsonants,
      overallProgressPercentage:
          overallProgressPercentage ?? this.overallProgressPercentage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PronunciationProgress &&
        _listEquals(other.vowelProgress, vowelProgress) &&
        _listEquals(other.consonantProgress, consonantProgress) &&
        other.totalVowels == totalVowels &&
        other.totalConsonants == totalConsonants &&
        other.overallProgressPercentage == overallProgressPercentage;
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return vowelProgress.hashCode ^
        consonantProgress.hashCode ^
        totalVowels.hashCode ^
        totalConsonants.hashCode ^
        overallProgressPercentage.hashCode;
  }

  @override
  String toString() {
    return 'PronunciationProgress(vowelProgress: $vowelProgress, consonantProgress: $consonantProgress, totalVowels: $totalVowels, totalConsonants: $totalConsonants, overallProgressPercentage: $overallProgressPercentage)';
  }

  // Business logic methods
  int get completedVowels =>
      vowelProgress.where((vowel) => vowel.isCompleted).length;

  int get completedConsonants =>
      consonantProgress.where((consonant) => consonant.isCompleted).length;

  double get vowelProgressPercentage =>
      totalVowels > 0 ? (completedVowels / totalVowels) * 100 : 0;

  double get consonantProgressPercentage =>
      totalConsonants > 0 ? (completedConsonants / totalConsonants) * 100 : 0;

  List<VowelProgress> get completedVowelsList =>
      vowelProgress.where((vowel) => vowel.isCompleted).toList();

  List<ConsonantProgress> get completedConsonantsList =>
      consonantProgress.where((consonant) => consonant.isCompleted).toList();

  List<VowelProgress> get inProgressVowelsList =>
      vowelProgress.where((vowel) => vowel.isInProgress).toList();

  List<ConsonantProgress> get inProgressConsonantsList =>
      consonantProgress.where((consonant) => consonant.isInProgress).toList();

  List<VowelProgress> get notStartedVowelsList =>
      vowelProgress.where((vowel) => vowel.isNotStarted).toList();

  List<ConsonantProgress> get notStartedConsonantsList =>
      consonantProgress.where((consonant) => consonant.isNotStarted).toList();

  List<VowelProgress> get vowelsNeedingReview =>
      vowelProgress.where((vowel) => vowel.needsReview).toList();

  List<ConsonantProgress> get consonantsNeedingReview =>
      consonantProgress.where((consonant) => consonant.needsReview).toList();

  bool get hasAnyProgress => overallProgressPercentage > 0;

  bool get isFullyCompleted => overallProgressPercentage == 100;

  // Get next recommended sound to practice
  VowelProgress? get nextVowelToStudy {
    // First prioritize sounds in progress
    final inProgress = inProgressVowelsList;
    if (inProgress.isNotEmpty) {
      return inProgress.first;
    }

    // Then sounds that need review
    final needReview = vowelsNeedingReview;
    if (needReview.isNotEmpty) {
      return needReview.first;
    }

    // Finally, not started sounds
    final notStarted = notStartedVowelsList;
    if (notStarted.isNotEmpty) {
      return notStarted.first;
    }

    return null;
  }

  ConsonantProgress? get nextConsonantToStudy {
    // First prioritize sounds in progress
    final inProgress = inProgressConsonantsList;
    if (inProgress.isNotEmpty) {
      return inProgress.first;
    }

    // Then sounds that need review
    final needReview = consonantsNeedingReview;
    if (needReview.isNotEmpty) {
      return needReview.first;
    }

    // Finally, not started sounds
    final notStarted = notStartedConsonantsList;
    if (notStarted.isNotEmpty) {
      return notStarted.first;
    }

    return null;
  }

  // Calculate estimated time to complete (in days)
  int get estimatedDaysToComplete {
    final remainingVowels = totalVowels - completedVowels;
    final remainingConsonants = totalConsonants - completedConsonants;
    final totalRemaining = remainingVowels + remainingConsonants;

    // Assuming average 1 sound per day
    return totalRemaining;
  }
}
