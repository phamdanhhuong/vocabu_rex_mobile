/// Enhanced Podcast Question System
/// Supports multiple question types: match, true/false, listen_choose, multiple_choice

enum PodcastQuestionType {
  match,
  trueFalse,
  listenChoose,
  multipleChoice,
}

/// Base class for all podcast question types
abstract class PodcastQuestionEntity {
  final PodcastQuestionType type;
  final String question;

  const PodcastQuestionEntity({
    required this.type,
    required this.question,
  });

  factory PodcastQuestionEntity.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String;
    final type = PodcastQuestionType.values.firstWhere(
      (e) => e.toString().split('.').last == typeStr,
      orElse: () => PodcastQuestionType.multipleChoice,
    );

    switch (type) {
      case PodcastQuestionType.match:
        return PodcastMatchQuestion.fromJson(json);
      case PodcastQuestionType.trueFalse:
        return PodcastTrueFalseQuestion.fromJson(json);
      case PodcastQuestionType.listenChoose:
        return PodcastListenChooseQuestion.fromJson(json);
      case PodcastQuestionType.multipleChoice:
        return PodcastMultipleChoiceQuestion.fromJson(json);
    }
  }

  Map<String, dynamic> toJson();
  
  /// Get correct answer for validation
  String getCorrectAnswer();
  
  /// Validate user's answer
  bool validateAnswer(dynamic userAnswer);
}

/// Match pairs question (e.g., match words with meanings)
class PodcastMatchQuestion extends PodcastQuestionEntity {
  final List<MatchPairEntity> pairs;

  const PodcastMatchQuestion({
    required String question,
    required this.pairs,
  }) : super(type: PodcastQuestionType.match, question: question);

  factory PodcastMatchQuestion.fromJson(Map<String, dynamic> json) {
    final pairsData = json['pairs'] as List;
    return PodcastMatchQuestion(
      question: json['question'] as String,
      pairs: pairsData
          .map((pair) => MatchPairEntity.fromJson(pair))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'match',
      'question': question,
      'pairs': pairs.map((p) => p.toJson()).toList(),
    };
  }

  @override
  String getCorrectAnswer() {
    // Return JSON string of correct pairs for logging
    return pairs.map((p) => '${p.left}=${p.right}').join(',');
  }

  @override
  bool validateAnswer(dynamic userAnswer) {
    if (userAnswer is! Map<String, String>) return false;
    
    // Check if all pairs are correctly matched
    for (var pair in pairs) {
      if (userAnswer[pair.left] != pair.right) {
        return false;
      }
    }
    return true;
  }
}

class MatchPairEntity {
  final String left;
  final String right;

  const MatchPairEntity({
    required this.left,
    required this.right,
  });

  factory MatchPairEntity.fromJson(Map<String, dynamic> json) {
    return MatchPairEntity(
      left: json['left'] as String,
      right: json['right'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'left': left,
      'right': right,
    };
  }
}

/// True or False question
class PodcastTrueFalseQuestion extends PodcastQuestionEntity {
  final String statement;
  final bool correctAnswer;
  final String? explanation; // Optional explanation for the answer

  const PodcastTrueFalseQuestion({
    required String question,
    required this.statement,
    required this.correctAnswer,
    this.explanation,
  }) : super(type: PodcastQuestionType.trueFalse, question: question);

  factory PodcastTrueFalseQuestion.fromJson(Map<String, dynamic> json) {
    final statement = json['statement'] as String;
    final question = json['question'] as String? ?? statement; // Use statement if no question
    
    return PodcastTrueFalseQuestion(
      question: question,
      statement: statement,
      correctAnswer: json['correctAnswer'] as bool,
      explanation: json['explanation'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'trueFalse',
      'question': question,
      'statement': statement,
      'correctAnswer': correctAnswer,
      if (explanation != null) 'explanation': explanation,
    };
  }

  @override
  String getCorrectAnswer() {
    return correctAnswer ? 'true' : 'false';
  }

  @override
  bool validateAnswer(dynamic userAnswer) {
    if (userAnswer is bool) {
      return userAnswer == correctAnswer;
    }
    if (userAnswer is String) {
      return userAnswer.toLowerCase() == getCorrectAnswer();
    }
    return false;
  }
}

/// Listen and choose words question (select words you hear)
class PodcastListenChooseQuestion extends PodcastQuestionEntity {
  final List<String> correctWords; // Words user should select
  final List<String> distractorWords; // Additional words that are NOT in audio
  
  /// All options = correctWords + distractorWords (shuffled in UI)
  List<String> get allOptions => [...correctWords, ...distractorWords];

  const PodcastListenChooseQuestion({
    required String question,
    required this.correctWords,
    required this.distractorWords,
  }) : super(type: PodcastQuestionType.listenChoose, question: question);

  factory PodcastListenChooseQuestion.fromJson(Map<String, dynamic> json) {
    return PodcastListenChooseQuestion(
      question: json['question'] as String,
      correctWords: List<String>.from(json['correctWords'] as List),
      distractorWords: List<String>.from(json['distractorWords'] as List),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'listenChoose',
      'question': question,
      'correctWords': correctWords,
      'distractorWords': distractorWords,
    };
  }

  @override
  String getCorrectAnswer() {
    return correctWords.join(', ');
  }

  @override
  bool validateAnswer(dynamic userAnswer) {
    if (userAnswer is! List) return false;
    
    final selectedWords = userAnswer.cast<String>().toSet();
    final correctSet = correctWords.toSet();
    
    // User must select exactly the correct words, no more, no less
    return selectedWords.length == correctSet.length &&
           selectedWords.containsAll(correctSet);
  }
}

/// Traditional multiple choice question
class PodcastMultipleChoiceQuestion extends PodcastQuestionEntity {
  final List<String> options;
  final String correctAnswer;

  const PodcastMultipleChoiceQuestion({
    required String question,
    required this.options,
    required this.correctAnswer,
  }) : super(type: PodcastQuestionType.multipleChoice, question: question);

  factory PodcastMultipleChoiceQuestion.fromJson(Map<String, dynamic> json) {
    return PodcastMultipleChoiceQuestion(
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswer: json['correctAnswer'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'multipleChoice',
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }

  @override
  String getCorrectAnswer() {
    return correctAnswer;
  }

  @override
  bool validateAnswer(dynamic userAnswer) {
    if (userAnswer is! String) return false;
    return userAnswer.trim().toLowerCase() == 
           correctAnswer.trim().toLowerCase();
  }
}
