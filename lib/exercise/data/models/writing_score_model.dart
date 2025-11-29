import 'package:vocabu_rex_mobile/exercise/domain/entities/writing_score_entity.dart';

class WritingScoreModel extends WritingScoreEntity {
  const WritingScoreModel({
    required super.isCorrect,
    required super.scorePercentage,
    required super.feedback,
    required super.performanceLevel,
  });

  factory WritingScoreModel.fromJson(Map<String, dynamic> json) {
    return WritingScoreModel(
      isCorrect: json['is_correct'] ?? false,
      scorePercentage: json['score_percentage'] ?? 0,
      feedback: json['feedback'] ?? '',
      performanceLevel: json['performance_level'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_correct': isCorrect,
      'score_percentage': scorePercentage,
      'feedback': feedback,
      'performance_level': performanceLevel,
    };
  }
}
