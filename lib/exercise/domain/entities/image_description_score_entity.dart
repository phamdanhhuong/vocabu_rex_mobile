import '../../data/models/image_description_score_model.dart';

class ImageDescriptionScoreEntity {
  final bool isCorrect;
  final int scorePercentage;
  final String feedback;
  final String similarityLevel;

  ImageDescriptionScoreEntity({
    required this.isCorrect,
    required this.scorePercentage,
    required this.feedback,
    required this.similarityLevel,
  });

  factory ImageDescriptionScoreEntity.fromModel(
    ImageDescriptionScoreModel model,
  ) {
    return ImageDescriptionScoreEntity(
      isCorrect: model.isCorrect,
      scorePercentage: model.scorePercentage,
      feedback: model.feedback,
      similarityLevel: model.similarityLevel,
    );
  }

  ImageDescriptionScoreEntity copyWith({
    bool? isCorrect,
    int? scorePercentage,
    String? feedback,
    String? similarityLevel,
  }) {
    return ImageDescriptionScoreEntity(
      isCorrect: isCorrect ?? this.isCorrect,
      scorePercentage: scorePercentage ?? this.scorePercentage,
      feedback: feedback ?? this.feedback,
      similarityLevel: similarityLevel ?? this.similarityLevel,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImageDescriptionScoreEntity &&
        other.isCorrect == isCorrect &&
        other.scorePercentage == scorePercentage &&
        other.feedback == feedback &&
        other.similarityLevel == similarityLevel;
  }

  @override
  int get hashCode {
    return isCorrect.hashCode ^
        scorePercentage.hashCode ^
        feedback.hashCode ^
        similarityLevel.hashCode;
  }

  @override
  String toString() {
    return 'ImageDescriptionScoreEntity('
        'isCorrect: $isCorrect, '
        'scorePercentage: $scorePercentage, '
        'feedback: $feedback, '
        'similarityLevel: $similarityLevel'
        ')';
  }

  // Convenience getters
  double get scoreDecimal => scorePercentage / 100.0;
  bool get isPassing => scorePercentage >= 50;
}
