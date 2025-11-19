import 'vowel_progress_model.dart';
import 'consonant_progress_model.dart';

class PronunciationProgressModel {
  final List<VowelProgressModel> vowelProgress;
  final List<ConsonantProgressModel> consonantProgress;
  final int totalVowels;
  final int totalConsonants;
  final int overallProgressPercentage;

  PronunciationProgressModel({
    required this.vowelProgress,
    required this.consonantProgress,
    required this.totalVowels,
    required this.totalConsonants,
    required this.overallProgressPercentage,
  });

  factory PronunciationProgressModel.fromJson(Map<String, dynamic> json) {
    return PronunciationProgressModel(
      vowelProgress:
          (json['vowelProgress'] as List<dynamic>?)
              ?.map(
                (item) =>
                    VowelProgressModel.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      consonantProgress:
          (json['consonantProgress'] as List<dynamic>?)
              ?.map(
                (item) => ConsonantProgressModel.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      totalVowels: json['totalVowels'] ?? 0,
      totalConsonants: json['totalConsonants'] ?? 0,
      overallProgressPercentage: json['overallProgressPercentage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vowelProgress': vowelProgress.map((item) => item.toJson()).toList(),
      'consonantProgress': consonantProgress
          .map((item) => item.toJson())
          .toList(),
      'totalVowels': totalVowels,
      'totalConsonants': totalConsonants,
      'overallProgressPercentage': overallProgressPercentage,
    };
  }

  PronunciationProgressModel copyWith({
    List<VowelProgressModel>? vowelProgress,
    List<ConsonantProgressModel>? consonantProgress,
    int? totalVowels,
    int? totalConsonants,
    int? overallProgressPercentage,
  }) {
    return PronunciationProgressModel(
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
    return other is PronunciationProgressModel &&
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
    return 'PronunciationProgressModel(vowelProgress: $vowelProgress, consonantProgress: $consonantProgress, totalVowels: $totalVowels, totalConsonants: $totalConsonants, overallProgressPercentage: $overallProgressPercentage)';
  }

  // Helper methods
  int get completedVowels =>
      vowelProgress.where((vowel) => vowel.progressPercentage == 100).length;

  int get completedConsonants => consonantProgress
      .where((consonant) => consonant.progressPercentage == 100)
      .length;

  double get vowelProgressPercentage =>
      totalVowels > 0 ? (completedVowels / totalVowels) * 100 : 0;

  double get consonantProgressPercentage =>
      totalConsonants > 0 ? (completedConsonants / totalConsonants) * 100 : 0;

  List<VowelProgressModel> get completedVowelsList =>
      vowelProgress.where((vowel) => vowel.progressPercentage == 100).toList();

  List<ConsonantProgressModel> get completedConsonantsList => consonantProgress
      .where((consonant) => consonant.progressPercentage == 100)
      .toList();

  List<VowelProgressModel> get inProgressVowelsList => vowelProgress
      .where(
        (vowel) =>
            vowel.progressPercentage > 0 && vowel.progressPercentage < 100,
      )
      .toList();

  List<ConsonantProgressModel> get inProgressConsonantsList => consonantProgress
      .where(
        (consonant) =>
            consonant.progressPercentage > 0 &&
            consonant.progressPercentage < 100,
      )
      .toList();
}
