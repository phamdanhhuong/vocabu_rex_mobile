import 'package:vocabu_rex_mobile/home/data/models/grammar_model.dart';

class GrammarEntity {
  final String id;
  final String rule;
  final String explanation;
  final List<String> examples;

  GrammarEntity({
    required this.id,
    required this.rule,
    required this.explanation,
    required this.examples,
  });

  factory GrammarEntity.fromModel(GrammarModel model) {
    return GrammarEntity(
      id: model.id,
      rule: model.rule,
      explanation: model.explanation,
      examples: model.examples,
    );
  }

  GrammarEntity copyWith({
    String? id,
    String? rule,
    String? explanation,
    List<String>? examples,
  }) {
    return GrammarEntity(
      id: id ?? this.id,
      rule: rule ?? this.rule,
      explanation: explanation ?? this.explanation,
      examples: examples ?? this.examples,
    );
  }
}
