import 'package:vocabu_rex_mobile/exercise/domain/entities/translate_score_entity.dart';

class TranslateScoreModel extends TranslateScoreEntity {
  const TranslateScoreModel({
    required super.isCorrect,
    required super.feedback,
  });

  factory TranslateScoreModel.fromJson(Map<String, dynamic> json) {
    return TranslateScoreModel(
      isCorrect: json['is_correct'] ?? false,
      feedback: json['feedback'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'is_correct': isCorrect, 'feedback': feedback};
  }
}
