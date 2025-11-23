class GrammarModel {
  final String id;
  final String rule;
  final String explanation;
  final List<String> examples;

  GrammarModel({
    required this.id,
    required this.rule,
    required this.explanation,
    required this.examples,
  });

  factory GrammarModel.fromJson(Map<String, dynamic> json) {
    return GrammarModel(
      id: json['id'] as String,
      rule: json['rule'] as String,
      explanation: json['explanation'] as String,
      examples: (json['examples'] as List).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rule': rule,
      'explanation': explanation,
      'examples': examples,
    };
  }
}
