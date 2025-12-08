class WritingScoreEntity {
  final bool isCorrect;
  final double scorePercentage;
  final String feedback;
  final String performanceLevel;

  const WritingScoreEntity({
    required this.isCorrect,
    required this.scorePercentage,
    required this.feedback,
    required this.performanceLevel,
  });

  @override
  String toString() {
    return 'WritingScoreEntity(isCorrect: $isCorrect, scorePercentage: $scorePercentage, feedback: $feedback, performanceLevel: $performanceLevel)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WritingScoreEntity &&
        other.isCorrect == isCorrect &&
        other.scorePercentage == scorePercentage &&
        other.feedback == feedback &&
        other.performanceLevel == performanceLevel;
  }

  @override
  int get hashCode {
    return isCorrect.hashCode ^
        scorePercentage.hashCode ^
        feedback.hashCode ^
        performanceLevel.hashCode;
  }
}
