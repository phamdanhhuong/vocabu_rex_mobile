class WritingErrorDetailEntity {
  final String original;
  final String corrected;
  final String explanation;

  const WritingErrorDetailEntity({
    required this.original,
    required this.corrected,
    required this.explanation,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WritingErrorDetailEntity &&
        other.original == original &&
        other.corrected == corrected &&
        other.explanation == explanation;
  }

  @override
  int get hashCode => original.hashCode ^ corrected.hashCode ^ explanation.hashCode;
}

class WritingScoreEntity {
  final bool isCorrect;
  final double scorePercentage;
  final String feedback;
  final String performanceLevel;
  final String? grammarFeedback;
  final String? vocabularyFeedback;
  final String? contentFeedback;
  final List<WritingErrorDetailEntity> detailedErrors;

  const WritingScoreEntity({
    required this.isCorrect,
    required this.scorePercentage,
    required this.feedback,
    required this.performanceLevel,
    this.grammarFeedback,
    this.vocabularyFeedback,
    this.contentFeedback,
    this.detailedErrors = const [],
  });

  @override
  String toString() {
    return 'WritingScoreEntity(isCorrect: $isCorrect, scorePercentage: $scorePercentage, feedback: $feedback, performanceLevel: $performanceLevel, detailedErrors: ${detailedErrors.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WritingScoreEntity &&
        other.isCorrect == isCorrect &&
        other.scorePercentage == scorePercentage &&
        other.feedback == feedback &&
        other.performanceLevel == performanceLevel &&
        other.grammarFeedback == grammarFeedback &&
        other.vocabularyFeedback == vocabularyFeedback &&
        other.contentFeedback == contentFeedback;
  }

  @override
  int get hashCode {
    return isCorrect.hashCode ^
        scorePercentage.hashCode ^
        feedback.hashCode ^
        performanceLevel.hashCode ^
        grammarFeedback.hashCode ^
        vocabularyFeedback.hashCode ^
        contentFeedback.hashCode;
  }
}
