// Base class for all exercise meta types
abstract class ExerciseMetaEntity {
  const ExerciseMetaEntity();

  factory ExerciseMetaEntity.fromJson(
    Map<String, dynamic> json,
    String exerciseType,
  ) {
    switch (exerciseType.toLowerCase()) {
      case 'listen_choose':
        return ListenChooseMetaEntity.fromJson(json);
      case 'multiple_choice':
        return MultipleChoiceMetaEntity.fromJson(json);
      case 'translate':
        return TranslateMetaEntity.fromJson(json);
      case 'fill_blank':
        return FillBlankMetaEntity.fromJson(json);
      case 'match':
        return MatchMetaEntity.fromJson(json);
      case 'podcast':
        return PodcastMetaEntity.fromJson(json);
      case 'writing_prompt':
        return WritingPromptMetaEntity.fromJson(json);
      default:
        return GenericMetaEntity.fromJson(json);
    }
  }

  Map<String, dynamic> toJson();
}

// Listen and choose exercise meta
class ListenChooseMetaEntity extends ExerciseMetaEntity {
  final String audioUrl;
  final String correctAnswer;
  final List<String> options;
  final String? word;

  const ListenChooseMetaEntity({
    required this.audioUrl,
    required this.correctAnswer,
    required this.options,
    this.word,
  });

  factory ListenChooseMetaEntity.fromJson(Map<String, dynamic> json) {
    return ListenChooseMetaEntity(
      audioUrl: json['audioUrl'] as String,
      correctAnswer: json['correctAnswer'] as String,
      options: List<String>.from(json['options'] as List),
      word: json['word'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'audioUrl': audioUrl,
      'correctAnswer': correctAnswer,
      'options': options,
      if (word != null) 'word': word,
    };
  }
}

// Multiple choice exercise meta
class MultipleChoiceMetaEntity extends ExerciseMetaEntity {
  final String word;
  final String correctAnswer;
  final List<String> options;

  const MultipleChoiceMetaEntity({
    required this.word,
    required this.correctAnswer,
    required this.options,
  });

  factory MultipleChoiceMetaEntity.fromJson(Map<String, dynamic> json) {
    return MultipleChoiceMetaEntity(
      word: json['word'] as String,
      correctAnswer: json['correctAnswer'] as String,
      options: List<String>.from(json['options'] as List),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'word': word, 'correctAnswer': correctAnswer, 'options': options};
  }
}

// Translation exercise meta
class TranslateMetaEntity extends ExerciseMetaEntity {
  final String word;
  final String correctAnswer;

  const TranslateMetaEntity({required this.word, required this.correctAnswer});

  factory TranslateMetaEntity.fromJson(Map<String, dynamic> json) {
    return TranslateMetaEntity(
      word: json['word'] as String,
      correctAnswer: json['correctAnswer'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'word': word, 'correctAnswer': correctAnswer};
  }
}

// Fill in the blank exercise meta
class FillBlankMetaEntity extends ExerciseMetaEntity {
  final String sentence;
  final String correctAnswer;
  final String? hint;
  final String? rule;
  final String? explanation;
  final String? example;

  const FillBlankMetaEntity({
    required this.sentence,
    required this.correctAnswer,
    this.hint,
    this.rule,
    this.explanation,
    this.example,
  });

  factory FillBlankMetaEntity.fromJson(Map<String, dynamic> json) {
    return FillBlankMetaEntity(
      sentence: json['sentence'] as String,
      correctAnswer: json['correctAnswer'] as String,
      hint: json['hint'] as String?,
      rule: json['rule'] as String?,
      explanation: json['explanation'] as String?,
      example: json['example'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'sentence': sentence,
      'correctAnswer': correctAnswer,
      if (hint != null) 'hint': hint,
      if (rule != null) 'rule': rule,
      if (explanation != null) 'explanation': explanation,
      if (example != null) 'example': example,
    };
  }
}

// Matching exercise meta
class WordMeaningPair {
  final String word;
  final String meaning;
  final String? pronunciation;

  const WordMeaningPair({
    required this.word,
    required this.meaning,
    this.pronunciation,
  });

  factory WordMeaningPair.fromJson(Map<String, dynamic> json) {
    return WordMeaningPair(
      word: json['word'] as String,
      meaning: json['meaning'] as String,
      pronunciation: json['pronunciation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'meaning': meaning,
      if (pronunciation != null) 'pronunciation': pronunciation,
    };
  }
}

class MatchMetaEntity extends ExerciseMetaEntity {
  final List<WordMeaningPair> pairs;

  const MatchMetaEntity({required this.pairs});

  factory MatchMetaEntity.fromJson(Map<String, dynamic> json) {
    final pairsData = json['pairs'] as List;
    return MatchMetaEntity(
      pairs: pairsData.map((pair) => WordMeaningPair.fromJson(pair)).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'pairs': pairs.map((pair) => pair.toJson()).toList()};
  }
}

// Podcast exercise meta
class PodcastQuestion {
  final String question;
  final String answer;

  const PodcastQuestion({required this.question, required this.answer});

  factory PodcastQuestion.fromJson(Map<String, dynamic> json) {
    return PodcastQuestion(
      question: json['question'] as String,
      answer: json['answer'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'question': question, 'answer': answer};
  }
}

class PodcastMetaEntity extends ExerciseMetaEntity {
  final String audioUrl;
  final String duration;
  final String transcript;
  final List<PodcastQuestion> questions;

  const PodcastMetaEntity({
    required this.audioUrl,
    required this.duration,
    required this.transcript,
    required this.questions,
  });

  factory PodcastMetaEntity.fromJson(Map<String, dynamic> json) {
    final questionsData = json['questions'] as List;
    return PodcastMetaEntity(
      audioUrl: json['audioUrl'] as String,
      duration: json['duration'] as String,
      transcript: json['transcript'] as String,
      questions: questionsData.map((q) => PodcastQuestion.fromJson(q)).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'audioUrl': audioUrl,
      'duration': duration,
      'transcript': transcript,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

// Writing prompt exercise meta
class WritingRubric {
  final String vocabulary;
  final String grammar;
  final String coherence;

  const WritingRubric({
    required this.vocabulary,
    required this.grammar,
    required this.coherence,
  });

  factory WritingRubric.fromJson(Map<String, dynamic> json) {
    return WritingRubric(
      vocabulary: json['vocabulary'] as String,
      grammar: json['grammar'] as String,
      coherence: json['coherence'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vocabulary': vocabulary,
      'grammar': grammar,
      'coherence': coherence,
    };
  }
}

class WritingPromptMetaEntity extends ExerciseMetaEntity {
  final int minWords;
  final int maxWords;
  final List<String> requiredWords;
  final WritingRubric rubric;

  const WritingPromptMetaEntity({
    required this.minWords,
    required this.maxWords,
    required this.requiredWords,
    required this.rubric,
  });

  factory WritingPromptMetaEntity.fromJson(Map<String, dynamic> json) {
    return WritingPromptMetaEntity(
      minWords: json['minWords'] as int,
      maxWords: json['maxWords'] as int,
      requiredWords: List<String>.from(json['requiredWords'] as List),
      rubric: WritingRubric.fromJson(json['rubric'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'minWords': minWords,
      'maxWords': maxWords,
      'requiredWords': requiredWords,
      'rubric': rubric.toJson(),
    };
  }
}

// Generic meta entity for unknown or flexible types
class GenericMetaEntity extends ExerciseMetaEntity {
  final Map<String, dynamic> data;

  const GenericMetaEntity({required this.data});

  factory GenericMetaEntity.fromJson(Map<String, dynamic> json) {
    return GenericMetaEntity(data: Map<String, dynamic>.from(json));
  }

  @override
  Map<String, dynamic> toJson() {
    return data;
  }
}
