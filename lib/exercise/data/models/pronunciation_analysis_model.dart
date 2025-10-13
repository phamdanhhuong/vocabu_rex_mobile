import '../../domain/entities/entities.dart';

class PronunciationAnalysisResponse {
  final int overallPronunciationScore;
  final double fluencyScore;
  final int accuracyScore;
  final double totalScore;
  final String pronunciationGrade;
  final List<WordComparison> wordComparisons;
  final PronunciationFeedback feedback;

  PronunciationAnalysisResponse({
    required this.overallPronunciationScore,
    required this.fluencyScore,
    required this.accuracyScore,
    required this.totalScore,
    required this.pronunciationGrade,
    required this.wordComparisons,
    required this.feedback,
  });

  factory PronunciationAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return PronunciationAnalysisResponse(
      overallPronunciationScore: json['overall_pronunciation_score'] as int,
      fluencyScore: (json['fluency_score'] as num).toDouble(),
      accuracyScore: json['accuracy_score'] as int,
      totalScore: (json['total_score'] as num).toDouble(),
      pronunciationGrade: json['pronunciation_grade'] as String,
      wordComparisons: (json['word_comparisons'] as List<dynamic>)
          .map((e) => WordComparison.fromJson(e as Map<String, dynamic>))
          .toList(),
      feedback: PronunciationFeedback.fromJson(
        json['feedback'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overall_pronunciation_score': overallPronunciationScore,
      'fluency_score': fluencyScore,
      'accuracy_score': accuracyScore,
      'total_score': totalScore,
      'pronunciation_grade': pronunciationGrade,
      'word_comparisons': wordComparisons.map((e) => e.toJson()).toList(),
      'feedback': feedback.toJson(),
    };
  }

  PronunciationAnalysisEntity toEntity() {
    return PronunciationAnalysisEntity(
      overallPronunciationScore: overallPronunciationScore,
      fluencyScore: fluencyScore,
      accuracyScore: accuracyScore,
      totalScore: totalScore,
      pronunciationGrade: pronunciationGrade,
      wordComparisons: wordComparisons.map((e) => e.toEntity()).toList(),
      feedback: feedback.toEntity(),
    );
  }
}

class PronunciationFeedback {
  final String overallFeedback;
  final List<String> strengths;
  final List<String> areasForImprovement;
  final List<String> specificPhonemeFeedback;
  final List<String> practiceSuggestions;
  final String difficultyLevelRecommendation;
  final String confidenceLevel;

  PronunciationFeedback({
    required this.overallFeedback,
    required this.strengths,
    required this.areasForImprovement,
    required this.specificPhonemeFeedback,
    required this.practiceSuggestions,
    required this.difficultyLevelRecommendation,
    required this.confidenceLevel,
  });

  factory PronunciationFeedback.fromJson(Map<String, dynamic> json) {
    return PronunciationFeedback(
      overallFeedback: json['overall_feedback'] as String,
      strengths: (json['strengths'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      areasForImprovement: (json['areas_for_improvement'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      specificPhonemeFeedback:
          (json['specific_phoneme_feedback'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      practiceSuggestions: (json['practice_suggestions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      difficultyLevelRecommendation:
          json['difficulty_level_recommendation'] as String,
      confidenceLevel: json['confidence_level'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overall_feedback': overallFeedback,
      'strengths': strengths,
      'areas_for_improvement': areasForImprovement,
      'specific_phoneme_feedback': specificPhonemeFeedback,
      'practice_suggestions': practiceSuggestions,
      'difficulty_level_recommendation': difficultyLevelRecommendation,
      'confidence_level': confidenceLevel,
    };
  }

  PronunciationFeedbackEntity toEntity() {
    return PronunciationFeedbackEntity(
      overallFeedback: overallFeedback,
      strengths: strengths,
      areasForImprovement: areasForImprovement,
      specificPhonemeFeedback: specificPhonemeFeedback,
      practiceSuggestions: practiceSuggestions,
      difficultyLevelRecommendation: difficultyLevelRecommendation,
      confidenceLevel: confidenceLevel,
    );
  }
}

class WordComparison {
  final String referenceWord;
  final String actualWord;
  final bool wordMatch;
  final List<PhonemeComparison> phonemeComparisons;
  final double overallAccuracy;
  final double timingAccuracy;

  WordComparison({
    required this.referenceWord,
    required this.actualWord,
    required this.wordMatch,
    required this.phonemeComparisons,
    required this.overallAccuracy,
    required this.timingAccuracy,
  });

  factory WordComparison.fromJson(Map<String, dynamic> json) {
    return WordComparison(
      referenceWord: json['reference_word'] as String,
      actualWord: json['actual_word'] as String,
      wordMatch: json['word_match'] as bool,
      phonemeComparisons: (json['phoneme_comparisons'] as List<dynamic>)
          .map((e) => PhonemeComparison.fromJson(e as Map<String, dynamic>))
          .toList(),
      overallAccuracy: (json['overall_accuracy'] as num).toDouble(),
      timingAccuracy: (json['timing_accuracy'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reference_word': referenceWord,
      'actual_word': actualWord,
      'word_match': wordMatch,
      'phoneme_comparisons': phonemeComparisons.map((e) => e.toJson()).toList(),
      'overall_accuracy': overallAccuracy,
      'timing_accuracy': timingAccuracy,
    };
  }

  WordComparisonEntity toEntity() {
    return WordComparisonEntity(
      referenceWord: referenceWord,
      actualWord: actualWord,
      wordMatch: wordMatch,
      phonemeComparisons: phonemeComparisons.map((e) => e.toEntity()).toList(),
      overallAccuracy: overallAccuracy,
      timingAccuracy: timingAccuracy,
    );
  }
}

class PhonemeComparison {
  final String referencePhoneme;
  final String actualPhoneme;
  final bool phonemeMatch;
  final double similarityScore;
  final double timingDeviation;
  final String? errorType;

  PhonemeComparison({
    required this.referencePhoneme,
    required this.actualPhoneme,
    required this.phonemeMatch,
    required this.similarityScore,
    required this.timingDeviation,
    this.errorType,
  });

  factory PhonemeComparison.fromJson(Map<String, dynamic> json) {
    return PhonemeComparison(
      referencePhoneme: json['reference_phoneme'] as String,
      actualPhoneme: json['actual_phoneme'] as String,
      phonemeMatch: json['phoneme_match'] as bool,
      similarityScore: (json['similarity_score'] as num).toDouble(),
      timingDeviation: (json['timing_deviation'] as num).toDouble(),
      errorType: json['error_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reference_phoneme': referencePhoneme,
      'actual_phoneme': actualPhoneme,
      'phoneme_match': phonemeMatch,
      'similarity_score': similarityScore,
      'timing_deviation': timingDeviation,
      'error_type': errorType,
    };
  }

  PhonemeComparisonEntity toEntity() {
    return PhonemeComparisonEntity(
      referencePhoneme: referencePhoneme,
      actualPhoneme: actualPhoneme,
      phonemeMatch: phonemeMatch,
      similarityScore: similarityScore,
      timingDeviation: timingDeviation,
      errorType: errorType,
    );
  }
}
