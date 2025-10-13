class PronunciationAnalysisEntity {
  final int overallPronunciationScore;
  final double fluencyScore;
  final int accuracyScore;
  final double totalScore;
  final String pronunciationGrade;
  final List<WordComparisonEntity> wordComparisons;
  final PronunciationFeedbackEntity feedback;

  const PronunciationAnalysisEntity({
    required this.overallPronunciationScore,
    required this.fluencyScore,
    required this.accuracyScore,
    required this.totalScore,
    required this.pronunciationGrade,
    required this.wordComparisons,
    required this.feedback,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PronunciationAnalysisEntity &&
        other.overallPronunciationScore == overallPronunciationScore &&
        other.fluencyScore == fluencyScore &&
        other.accuracyScore == accuracyScore &&
        other.totalScore == totalScore &&
        other.pronunciationGrade == pronunciationGrade &&
        other.wordComparisons == wordComparisons &&
        other.feedback == feedback;
  }

  @override
  int get hashCode {
    return overallPronunciationScore.hashCode ^
        fluencyScore.hashCode ^
        accuracyScore.hashCode ^
        totalScore.hashCode ^
        pronunciationGrade.hashCode ^
        wordComparisons.hashCode ^
        feedback.hashCode;
  }

  @override
  String toString() {
    return 'PronunciationAnalysisEntity('
        'overallPronunciationScore: $overallPronunciationScore, '
        'fluencyScore: $fluencyScore, '
        'accuracyScore: $accuracyScore, '
        'totalScore: $totalScore, '
        'pronunciationGrade: $pronunciationGrade, '
        'wordComparisons: $wordComparisons, '
        'feedback: $feedback)';
  }
}

class PronunciationFeedbackEntity {
  final String overallFeedback;
  final List<String> strengths;
  final List<String> areasForImprovement;
  final List<String> specificPhonemeFeedback;
  final List<String> practiceSuggestions;
  final String difficultyLevelRecommendation;
  final String confidenceLevel;

  const PronunciationFeedbackEntity({
    required this.overallFeedback,
    required this.strengths,
    required this.areasForImprovement,
    required this.specificPhonemeFeedback,
    required this.practiceSuggestions,
    required this.difficultyLevelRecommendation,
    required this.confidenceLevel,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PronunciationFeedbackEntity &&
        other.overallFeedback == overallFeedback &&
        other.strengths == strengths &&
        other.areasForImprovement == areasForImprovement &&
        other.specificPhonemeFeedback == specificPhonemeFeedback &&
        other.practiceSuggestions == practiceSuggestions &&
        other.difficultyLevelRecommendation == difficultyLevelRecommendation &&
        other.confidenceLevel == confidenceLevel;
  }

  @override
  int get hashCode {
    return overallFeedback.hashCode ^
        strengths.hashCode ^
        areasForImprovement.hashCode ^
        specificPhonemeFeedback.hashCode ^
        practiceSuggestions.hashCode ^
        difficultyLevelRecommendation.hashCode ^
        confidenceLevel.hashCode;
  }

  @override
  String toString() {
    return 'PronunciationFeedbackEntity('
        'overallFeedback: $overallFeedback, '
        'strengths: $strengths, '
        'areasForImprovement: $areasForImprovement, '
        'specificPhonemeFeedback: $specificPhonemeFeedback, '
        'practiceSuggestions: $practiceSuggestions, '
        'difficultyLevelRecommendation: $difficultyLevelRecommendation, '
        'confidenceLevel: $confidenceLevel)';
  }
}

class WordComparisonEntity {
  final String referenceWord;
  final String actualWord;
  final bool wordMatch;
  final List<PhonemeComparisonEntity> phonemeComparisons;
  final double overallAccuracy;
  final double timingAccuracy;

  const WordComparisonEntity({
    required this.referenceWord,
    required this.actualWord,
    required this.wordMatch,
    required this.phonemeComparisons,
    required this.overallAccuracy,
    required this.timingAccuracy,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WordComparisonEntity &&
        other.referenceWord == referenceWord &&
        other.actualWord == actualWord &&
        other.wordMatch == wordMatch &&
        other.phonemeComparisons == phonemeComparisons &&
        other.overallAccuracy == overallAccuracy &&
        other.timingAccuracy == timingAccuracy;
  }

  @override
  int get hashCode {
    return referenceWord.hashCode ^
        actualWord.hashCode ^
        wordMatch.hashCode ^
        phonemeComparisons.hashCode ^
        overallAccuracy.hashCode ^
        timingAccuracy.hashCode;
  }

  @override
  String toString() {
    return 'WordComparisonEntity('
        'referenceWord: $referenceWord, '
        'actualWord: $actualWord, '
        'wordMatch: $wordMatch, '
        'phonemeComparisons: $phonemeComparisons, '
        'overallAccuracy: $overallAccuracy, '
        'timingAccuracy: $timingAccuracy)';
  }
}

class PhonemeComparisonEntity {
  final String referencePhoneme;
  final String actualPhoneme;
  final bool phonemeMatch;
  final double similarityScore;
  final double timingDeviation;
  final String? errorType;

  const PhonemeComparisonEntity({
    required this.referencePhoneme,
    required this.actualPhoneme,
    required this.phonemeMatch,
    required this.similarityScore,
    required this.timingDeviation,
    this.errorType,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PhonemeComparisonEntity &&
        other.referencePhoneme == referencePhoneme &&
        other.actualPhoneme == actualPhoneme &&
        other.phonemeMatch == phonemeMatch &&
        other.similarityScore == similarityScore &&
        other.timingDeviation == timingDeviation &&
        other.errorType == errorType;
  }

  @override
  int get hashCode {
    return referencePhoneme.hashCode ^
        actualPhoneme.hashCode ^
        phonemeMatch.hashCode ^
        similarityScore.hashCode ^
        timingDeviation.hashCode ^
        errorType.hashCode;
  }

  @override
  String toString() {
    return 'PhonemeComparisonEntity('
        'referencePhoneme: $referencePhoneme, '
        'actualPhoneme: $actualPhoneme, '
        'phonemeMatch: $phonemeMatch, '
        'similarityScore: $similarityScore, '
        'timingDeviation: $timingDeviation, '
        'errorType: $errorType)';
  }
}
