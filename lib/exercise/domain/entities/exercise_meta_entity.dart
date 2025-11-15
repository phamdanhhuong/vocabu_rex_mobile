import 'enhanced_podcast_meta_entity.dart';

// Base class for all exercise meta types
abstract class ExerciseMetaEntity {
  const ExerciseMetaEntity();

  factory ExerciseMetaEntity.fromJson(
    Map<String, dynamic> json,
    String exerciseType,
  ) {
    switch (exerciseType.toLowerCase()) {
      case 'translate':
        return TranslateMetaEntity.fromJson(json);
      case 'listen_choose':
        return ListenChooseMetaEntity.fromJson(json);
      case 'fill_blank':
        return FillBlankMetaEntity.fromJson(json);
      case 'speak':
        return SpeakMetaEntity.fromJson(json);
      case 'match':
        return MatchMetaEntity.fromJson(json);
      case 'multiple_choice':
        return MultipleChoiceMetaEntity.fromJson(json);
      case 'writing_prompt':
        return WritingPromptMetaEntity.fromJson(json);
      case 'image_description':
        return ImageDescriptionMetaEntity.fromJson(json);
      case 'read_comprehension':
        return ReadComprehensionMetaEntity.fromJson(json);
      case 'podcast':
        return EnhancedPodcastMetaEntity.fromJson(json);
      default:
        return GenericMetaEntity.fromJson(json);
    }
  }

  Map<String, dynamic> toJson();
}

// Listen and choose exercise meta
class ListenChooseMetaEntity extends ExerciseMetaEntity {
  final String correctAnswer;
  final List<String> options;
  final String sentence;
  /// Input mode: 'select' (choose from tiles) or 'type' (fill-in-blank).
  ///
  /// IMPORTANT: The backend SHOULD NOT randomize the mode. If the backend
  /// omits the `mode` field (i.e. it's null), the client will decide
  /// (randomize between 'select' and 'type'). If the backend wants to force
  /// a mode, it should provide either 'select' or 'type'.
  final String? mode;

  const ListenChooseMetaEntity({
    required this.correctAnswer,
    required this.options,
    required this.sentence,
    this.mode,
  });

  factory ListenChooseMetaEntity.fromJson(Map<String, dynamic> json) {
    return ListenChooseMetaEntity(
      correctAnswer: json['correctAnswer'] as String,
      options: List<String>.from(json['options'] as List),
      sentence: json['sentence'] as String,
      mode: json['mode'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {
      'correctAnswer': correctAnswer,
      'options': options,
      'sentence': sentence,
    };
    if (mode != null) {
      map['mode'] = mode;
    }
    return map;
  }
}

// Multiple choice exercise meta
class MultipleChoiceOption {
  final String text;
  final int order; // -1 is interference option

  const MultipleChoiceOption({required this.text, required this.order});

  factory MultipleChoiceOption.fromJson(Map<String, dynamic> json) {
    return MultipleChoiceOption(
      text: json['text'] as String,
      order: json['order'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'order': order};
  }
}

class MultipleChoiceMetaEntity extends ExerciseMetaEntity {
  final String question;
  final List<MultipleChoiceOption> options;
  final List<int> correctOrder;

  const MultipleChoiceMetaEntity({
    required this.question,
    required this.options,
    required this.correctOrder,
  });

  factory MultipleChoiceMetaEntity.fromJson(Map<String, dynamic> json) {
    final optionsData = json['options'] as List;
    return MultipleChoiceMetaEntity(
      question: json['question'] as String,
      options: optionsData
          .map((option) => MultipleChoiceOption.fromJson(option))
          .toList(),
      correctOrder: List<int>.from(json['correctOrder'] as List),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options.map((option) => option.toJson()).toList(),
      'correctOrder': correctOrder,
    };
  }
}

// Translation exercise meta
class TranslateMetaEntity extends ExerciseMetaEntity {
  final String sourceText;
  final String correctAnswer;
  final List<String>? hints;

  const TranslateMetaEntity({
    required this.sourceText,
    required this.correctAnswer,
    this.hints,
  });

  factory TranslateMetaEntity.fromJson(Map<String, dynamic> json) {
    return TranslateMetaEntity(
      sourceText: json['sourceText'] as String,
      correctAnswer: json['correctAnswer'] as String,
      hints: json['hints'] != null
          ? List<String>.from(json['hints'] as List)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'sourceText': sourceText,
      'correctAnswer': correctAnswer,
      if (hints != null) 'hints': hints,
    };
  }
}

// Fill in the blank exercise meta
class FillBlankSentence {
  final String text;
  final String correctAnswer;
  final List<String>? options;

  const FillBlankSentence({
    required this.text,
    required this.correctAnswer,
    this.options,
  });

  factory FillBlankSentence.fromJson(Map<String, dynamic> json) {
    return FillBlankSentence(
      text: json['text'] as String,
      correctAnswer: json['correctAnswer'] as String,
      options: json['options'] != null
          ? List<String>.from(json['options'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'correctAnswer': correctAnswer,
      if (options != null) 'options': options,
    };
  }
}

class FillBlankMetaEntity extends ExerciseMetaEntity {
  final List<FillBlankSentence> sentences;
  final String? context;

  const FillBlankMetaEntity({required this.sentences, this.context});

  factory FillBlankMetaEntity.fromJson(Map<String, dynamic> json) {
    final sentencesData = json['sentences'] as List;
    return FillBlankMetaEntity(
      sentences: sentencesData
          .map((sentence) => FillBlankSentence.fromJson(sentence))
          .toList(),
      context: json['context'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'sentences': sentences.map((sentence) => sentence.toJson()).toList(),
      if (context != null) 'context': context,
    };
  }
}

// Speak exercise meta
class SpeakMetaEntity extends ExerciseMetaEntity {
  final String prompt;
  final String expectedText;

  const SpeakMetaEntity({required this.prompt, required this.expectedText});

  factory SpeakMetaEntity.fromJson(Map<String, dynamic> json) {
    return SpeakMetaEntity(
      prompt: json['prompt'] as String,
      expectedText: json['expectedText'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'prompt': prompt, 'expectedText': expectedText};
  }
}

// Matching exercise meta
class MatchPair {
  final String left;
  final String right;

  const MatchPair({required this.left, required this.right});

  factory MatchPair.fromJson(Map<String, dynamic> json) {
    return MatchPair(
      left: json['left'] as String,
      right: json['right'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'left': left, 'right': right};
  }
}

class MatchMetaEntity extends ExerciseMetaEntity {
  final List<MatchPair> pairs;

  const MatchMetaEntity({required this.pairs});

  factory MatchMetaEntity.fromJson(Map<String, dynamic> json) {
    final pairsData = json['pairs'] as List;
    return MatchMetaEntity(
      pairs: pairsData.map((pair) => MatchPair.fromJson(pair)).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'pairs': pairs.map((pair) => pair.toJson()).toList()};
  }
}

// Image description exercise meta
class ImageDescriptionMetaEntity extends ExerciseMetaEntity {
  final String imageUrl;
  final String prompt;
  final String expectedResults;

  const ImageDescriptionMetaEntity({
    required this.imageUrl,
    required this.prompt,
    required this.expectedResults,
  });

  factory ImageDescriptionMetaEntity.fromJson(Map<String, dynamic> json) {
    return ImageDescriptionMetaEntity(
      imageUrl: json['imageUrl'] as String,
      prompt: json['prompt'] as String,
      expectedResults: json['expectedResults'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'prompt': prompt,
      'expectedResults': expectedResults,
    };
  }
}

// Read comprehension exercise meta
class ReadComprehensionQuestion {
  final String question;
  final List<String> options;
  final String correctAnswer;

  const ReadComprehensionQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory ReadComprehensionQuestion.fromJson(Map<String, dynamic> json) {
    return ReadComprehensionQuestion(
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswer: json['correctAnswer'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }
}

class ReadComprehensionMetaEntity extends ExerciseMetaEntity {
  final String passage;
  final List<ReadComprehensionQuestion> questions;

  const ReadComprehensionMetaEntity({
    required this.passage,
    required this.questions,
  });

  factory ReadComprehensionMetaEntity.fromJson(Map<String, dynamic> json) {
    final questionsData = json['questions'] as List;
    return ReadComprehensionMetaEntity(
      passage: json['passage'] as String,
      questions: questionsData
          .map((q) => ReadComprehensionQuestion.fromJson(q))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'passage': passage,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

// Podcast exercise meta
class PodcastQuestion {
  final String question;
  final List<String> options;
  final String correctAnswer;

  const PodcastQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory PodcastQuestion.fromJson(Map<String, dynamic> json) {
    return PodcastQuestion(
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswer: json['correctAnswer'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }
}

class PodcastSegment {
  final int order; // Thứ tự của đoạn trong podcast
  final String transcript; // Nội dung lời thoại của đoạn
  final String voiceGender; // Giọng đọc của người nói ('male' hoặc 'female')
  final List<PodcastQuestion>? questions; // Câu hỏi giữa chừng (nếu có)

  const PodcastSegment({
    required this.order,
    required this.transcript,
    required this.voiceGender,
    this.questions,
  });

  factory PodcastSegment.fromJson(Map<String, dynamic> json) {
    final questionsData = json['questions'];
    List<PodcastQuestion>? questionsList;
    
    if (questionsData != null && questionsData is List && questionsData.isNotEmpty) {
      questionsList = questionsData
          .map((q) => PodcastQuestion.fromJson(q as Map<String, dynamic>))
          .toList();
    }
    
    return PodcastSegment(
      order: json['order'] as int,
      transcript: json['transcript'] as String,
      voiceGender: json['voiceGender'] as String,
      questions: questionsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': order,
      'transcript': transcript,
      'voiceGender': voiceGender,
      if (questions != null)
        'questions': questions!.map((q) => q.toJson()).toList(),
    };
  }
}

class PodcastMetaEntity extends ExerciseMetaEntity {
  final String title; // Tên podcast hoặc chủ đề
  final String? description; // Mô tả ngắn
  final List<PodcastSegment> segments; // Danh sách các đoạn trong podcast

  const PodcastMetaEntity({
    required this.title,
    this.description,
    required this.segments,
  });

  factory PodcastMetaEntity.fromJson(Map<String, dynamic> json) {
    final segmentsData = json['segments'] as List;
    return PodcastMetaEntity(
      title: json['title'] as String,
      description: json['description'] as String?,
      segments: segmentsData.map((s) => PodcastSegment.fromJson(s)).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (description != null) 'description': description,
      'segments': segments.map((s) => s.toJson()).toList(),
    };
  }
}

// Writing prompt exercise meta
class WritingPromptMetaEntity extends ExerciseMetaEntity {
  final String prompt;
  final int? minWords;
  final int? maxWords;
  final String? exampleAnswer;
  final List<String>? criteria;

  const WritingPromptMetaEntity({
    required this.prompt,
    this.minWords,
    this.maxWords,
    this.exampleAnswer,
    this.criteria,
  });

  factory WritingPromptMetaEntity.fromJson(Map<String, dynamic> json) {
    return WritingPromptMetaEntity(
      prompt: json['prompt'] as String,
      minWords: json['minWords'] as int?,
      maxWords: json['maxWords'] as int?,
      exampleAnswer: json['exampleAnswer'] as String?,
      criteria: json['criteria'] != null
          ? List<String>.from(json['criteria'] as List)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'prompt': prompt,
      if (minWords != null) 'minWords': minWords,
      if (maxWords != null) 'maxWords': maxWords,
      if (exampleAnswer != null) 'exampleAnswer': exampleAnswer,
      if (criteria != null) 'criteria': criteria,
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
