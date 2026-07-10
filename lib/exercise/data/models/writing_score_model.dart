import 'package:vocabu_rex_mobile/exercise/domain/entities/writing_score_entity.dart';

class WritingErrorDetailModel extends WritingErrorDetailEntity {
  const WritingErrorDetailModel({
    required super.original,
    required super.corrected,
    required super.explanation,
  });

  factory WritingErrorDetailModel.fromJson(Map<String, dynamic> json) {
    return WritingErrorDetailModel(
      original: json['original'] ?? '',
      corrected: json['corrected'] ?? '',
      explanation: json['explanation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'original': original,
      'corrected': corrected,
      'explanation': explanation,
    };
  }
}

class WritingScoreModel extends WritingScoreEntity {
  const WritingScoreModel({
    required super.isCorrect,
    required super.scorePercentage,
    required super.feedback,
    required super.performanceLevel,
    super.grammarFeedback,
    super.vocabularyFeedback,
    super.contentFeedback,
    super.detailedErrors,
  });

  factory WritingScoreModel.fromJson(Map<String, dynamic> json) {
    return WritingScoreModel(
      isCorrect: json['is_correct'] ?? false,
      scorePercentage: (json['score_percentage'] ?? 0).toDouble(),
      feedback: json['feedback'] ?? '',
      performanceLevel: json['performance_level'] ?? '',
      grammarFeedback: json['grammar_feedback'],
      vocabularyFeedback: json['vocabulary_feedback'],
      contentFeedback: json['content_feedback'],
      detailedErrors: (json['detailed_errors'] as List<dynamic>?)
              ?.map((e) => WritingErrorDetailModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_correct': isCorrect,
      'score_percentage': scorePercentage,
      'feedback': feedback,
      'performance_level': performanceLevel,
      'grammar_feedback': grammarFeedback,
      'vocabulary_feedback': vocabularyFeedback,
      'content_feedback': contentFeedback,
      'detailed_errors': detailedErrors.map((e) => (e as WritingErrorDetailModel).toJson()).toList(),
    };
  }
}
