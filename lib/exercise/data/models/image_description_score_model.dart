class ImageDescriptionScoreModel {
  final bool isCorrect;
  final int scorePercentage;
  final String feedback;
  final String similarityLevel;

  ImageDescriptionScoreModel({
    required this.isCorrect,
    required this.scorePercentage,
    required this.feedback,
    required this.similarityLevel,
  });

  factory ImageDescriptionScoreModel.fromJson(Map<String, dynamic> json) {
    return ImageDescriptionScoreModel(
      isCorrect: json['is_correct'] as bool,
      scorePercentage: (json['score_percentage'] as num).toInt(),
      feedback: json['feedback'] as String,
      similarityLevel: json['similarity_level'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isCorrect': isCorrect,
      'scorePercentage': scorePercentage,
      'feedback': feedback,
      'similarityLevel': similarityLevel,
    };
  }

  ImageDescriptionScoreModel copyWith({
    bool? isCorrect,
    int? scorePercentage,
    String? feedback,
    String? similarityLevel,
  }) {
    return ImageDescriptionScoreModel(
      isCorrect: isCorrect ?? this.isCorrect,
      scorePercentage: scorePercentage ?? this.scorePercentage,
      feedback: feedback ?? this.feedback,
      similarityLevel: similarityLevel ?? this.similarityLevel,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImageDescriptionScoreModel &&
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
    return 'ImageDescriptionScoreModel('
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
