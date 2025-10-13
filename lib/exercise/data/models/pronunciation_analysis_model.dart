class PronunciationAnalysisResponse {
  final bool success;
  final String audioFilePath;
  final String referenceText;
  final ActualUtterance actualUtterance;
  final List<WordComparison> wordComparisons;
  final int overallPronunciationScore;
  final double fluencyScore;
  final int accuracyScore;
  final double totalScore;
  final String pronunciationGrade;
  final PronunciationStatistics statistics;
  final PronunciationFeedback feedback;
  final double processingTimeMs;
  final String timestamp;
  final String whisperModelUsed;
  final Map<String, dynamic> metadata;
  final String? errorMessage;

  PronunciationAnalysisResponse({
    required this.success,
    required this.audioFilePath,
    required this.referenceText,
    required this.actualUtterance,
    required this.wordComparisons,
    required this.overallPronunciationScore,
    required this.fluencyScore,
    required this.accuracyScore,
    required this.totalScore,
    required this.pronunciationGrade,
    required this.statistics,
    required this.feedback,
    required this.processingTimeMs,
    required this.timestamp,
    required this.whisperModelUsed,
    required this.metadata,
    this.errorMessage,
  });

  factory PronunciationAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return PronunciationAnalysisResponse(
      success: json['success'] as bool,
      audioFilePath: json['audio_file_path'] as String,
      referenceText: json['reference_text'] as String,
      actualUtterance: ActualUtterance.fromJson(
        json['actual_utterance'] as Map<String, dynamic>,
      ),
      wordComparisons: (json['word_comparisons'] as List<dynamic>)
          .map((e) => WordComparison.fromJson(e as Map<String, dynamic>))
          .toList(),
      overallPronunciationScore: json['overall_pronunciation_score'] as int,
      fluencyScore: (json['fluency_score'] as num).toDouble(),
      accuracyScore: json['accuracy_score'] as int,
      totalScore: (json['total_score'] as num).toDouble(),
      pronunciationGrade: json['pronunciation_grade'] as String,
      statistics: PronunciationStatistics.fromJson(
        json['statistics'] as Map<String, dynamic>,
      ),
      feedback: PronunciationFeedback.fromJson(
        json['feedback'] as Map<String, dynamic>,
      ),
      processingTimeMs: (json['processing_time_ms'] as num).toDouble(),
      timestamp: json['timestamp'] as String,
      whisperModelUsed: json['whisper_model_used'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
      errorMessage: json['error_message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'audio_file_path': audioFilePath,
      'reference_text': referenceText,
      'actual_utterance': actualUtterance.toJson(),
      'word_comparisons': wordComparisons.map((e) => e.toJson()).toList(),
      'overall_pronunciation_score': overallPronunciationScore,
      'fluency_score': fluencyScore,
      'accuracy_score': accuracyScore,
      'total_score': totalScore,
      'pronunciation_grade': pronunciationGrade,
      'statistics': statistics.toJson(),
      'feedback': feedback.toJson(),
      'processing_time_ms': processingTimeMs,
      'timestamp': timestamp,
      'whisper_model_used': whisperModelUsed,
      'metadata': metadata,
      'error_message': errorMessage,
    };
  }
}

class ActualUtterance {
  final String transcribedText;
  final String originalText;
  final double totalDuration;
  final List<WordAnalysis> words;
  final double overallConfidence;
  final String transcriptionQuality;
  final String pronunciationAccuracy;
  final double speechRate;
  final double phonemeRate;
  final int pauseCount;
  final double pauseDurationTotal;

  ActualUtterance({
    required this.transcribedText,
    required this.originalText,
    required this.totalDuration,
    required this.words,
    required this.overallConfidence,
    required this.transcriptionQuality,
    required this.pronunciationAccuracy,
    required this.speechRate,
    required this.phonemeRate,
    required this.pauseCount,
    required this.pauseDurationTotal,
  });

  factory ActualUtterance.fromJson(Map<String, dynamic> json) {
    return ActualUtterance(
      transcribedText: json['transcribed_text'] as String,
      originalText: json['original_text'] as String,
      totalDuration: (json['total_duration'] as num).toDouble(),
      words: (json['words'] as List<dynamic>)
          .map((e) => WordAnalysis.fromJson(e as Map<String, dynamic>))
          .toList(),
      overallConfidence: (json['overall_confidence'] as num).toDouble(),
      transcriptionQuality: json['transcription_quality'] as String,
      pronunciationAccuracy: json['pronunciation_accuracy'] as String,
      speechRate: (json['speech_rate'] as num).toDouble(),
      phonemeRate: (json['phoneme_rate'] as num).toDouble(),
      pauseCount: json['pause_count'] as int,
      pauseDurationTotal: (json['pause_duration_total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transcribed_text': transcribedText,
      'original_text': originalText,
      'total_duration': totalDuration,
      'words': words.map((e) => e.toJson()).toList(),
      'overall_confidence': overallConfidence,
      'transcription_quality': transcriptionQuality,
      'pronunciation_accuracy': pronunciationAccuracy,
      'speech_rate': speechRate,
      'phoneme_rate': phonemeRate,
      'pause_count': pauseCount,
      'pause_duration_total': pauseDurationTotal,
    };
  }
}

class WordAnalysis {
  final String word;
  final double startTime;
  final double endTime;
  final double duration;
  final double confidence;
  final List<PhonemeAnalysis> phonemes;
  final double? pronunciationScore;

  WordAnalysis({
    required this.word,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.confidence,
    required this.phonemes,
    this.pronunciationScore,
  });

  factory WordAnalysis.fromJson(Map<String, dynamic> json) {
    return WordAnalysis(
      word: json['word'] as String,
      startTime: (json['start_time'] as num).toDouble(),
      endTime: (json['end_time'] as num).toDouble(),
      duration: (json['duration'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      phonemes: (json['phonemes'] as List<dynamic>)
          .map((e) => PhonemeAnalysis.fromJson(e as Map<String, dynamic>))
          .toList(),
      pronunciationScore: json['pronunciation_score'] != null
          ? (json['pronunciation_score'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'start_time': startTime,
      'end_time': endTime,
      'duration': duration,
      'confidence': confidence,
      'phonemes': phonemes.map((e) => e.toJson()).toList(),
      'pronunciation_score': pronunciationScore,
    };
  }
}

class PhonemeAnalysis {
  final String phoneme;
  final double startTime;
  final double endTime;
  final double duration;
  final double confidence;
  final double amplitude;
  final double? fundamentalFrequency;

  PhonemeAnalysis({
    required this.phoneme,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.confidence,
    required this.amplitude,
    this.fundamentalFrequency,
  });

  factory PhonemeAnalysis.fromJson(Map<String, dynamic> json) {
    return PhonemeAnalysis(
      phoneme: json['phoneme'] as String,
      startTime: (json['start_time'] as num).toDouble(),
      endTime: (json['end_time'] as num).toDouble(),
      duration: (json['duration'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      amplitude: (json['amplitude'] as num).toDouble(),
      fundamentalFrequency: json['fundamental_frequency'] != null
          ? (json['fundamental_frequency'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phoneme': phoneme,
      'start_time': startTime,
      'end_time': endTime,
      'duration': duration,
      'confidence': confidence,
      'amplitude': amplitude,
      'fundamental_frequency': fundamentalFrequency,
    };
  }
}

class WordComparison {
  final String referenceWord;
  final String actualWord;
  final bool wordMatch;
  final List<PhonemeComparison> phonemeComparisons;
  final double overallAccuracy;
  final double timingAccuracy;

  WordComparison({
    required this.referenceWord,
    required this.actualWord,
    required this.wordMatch,
    required this.phonemeComparisons,
    required this.overallAccuracy,
    required this.timingAccuracy,
  });

  factory WordComparison.fromJson(Map<String, dynamic> json) {
    return WordComparison(
      referenceWord: json['reference_word'] as String,
      actualWord: json['actual_word'] as String,
      wordMatch: json['word_match'] as bool,
      phonemeComparisons: (json['phoneme_comparisons'] as List<dynamic>)
          .map((e) => PhonemeComparison.fromJson(e as Map<String, dynamic>))
          .toList(),
      overallAccuracy: (json['overall_accuracy'] as num).toDouble(),
      timingAccuracy: (json['timing_accuracy'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reference_word': referenceWord,
      'actual_word': actualWord,
      'word_match': wordMatch,
      'phoneme_comparisons': phonemeComparisons.map((e) => e.toJson()).toList(),
      'overall_accuracy': overallAccuracy,
      'timing_accuracy': timingAccuracy,
    };
  }
}

class PhonemeComparison {
  final String referencePhoneme;
  final String actualPhoneme;
  final bool phonemeMatch;
  final double similarityScore;
  final double timingDeviation;
  final String? errorType;

  PhonemeComparison({
    required this.referencePhoneme,
    required this.actualPhoneme,
    required this.phonemeMatch,
    required this.similarityScore,
    required this.timingDeviation,
    this.errorType,
  });

  factory PhonemeComparison.fromJson(Map<String, dynamic> json) {
    return PhonemeComparison(
      referencePhoneme: json['reference_phoneme'] as String,
      actualPhoneme: json['actual_phoneme'] as String,
      phonemeMatch: json['phoneme_match'] as bool,
      similarityScore: (json['similarity_score'] as num).toDouble(),
      timingDeviation: (json['timing_deviation'] as num).toDouble(),
      errorType: json['error_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reference_phoneme': referencePhoneme,
      'actual_phoneme': actualPhoneme,
      'phoneme_match': phonemeMatch,
      'similarity_score': similarityScore,
      'timing_deviation': timingDeviation,
      'error_type': errorType,
    };
  }
}

class PronunciationStatistics {
  final double wordErrorRate;
  final double characterErrorRate;
  final double phonemeErrorRate;
  final double averageWordDuration;
  final double averagePhonemesDuration;
  final double timingPrecision;
  final int correctlyPronouncedPhonemes;
  final int totalPhonemes;
  final int phonemeAccuracyPercentage;
  final double speakingSpeed;
  final int pausePatternsScore;
  final int rhythmScore;
  final ConfidenceDistribution confidenceDistribution;

  PronunciationStatistics({
    required this.wordErrorRate,
    required this.characterErrorRate,
    required this.phonemeErrorRate,
    required this.averageWordDuration,
    required this.averagePhonemesDuration,
    required this.timingPrecision,
    required this.correctlyPronouncedPhonemes,
    required this.totalPhonemes,
    required this.phonemeAccuracyPercentage,
    required this.speakingSpeed,
    required this.pausePatternsScore,
    required this.rhythmScore,
    required this.confidenceDistribution,
  });

  factory PronunciationStatistics.fromJson(Map<String, dynamic> json) {
    return PronunciationStatistics(
      wordErrorRate: (json['word_error_rate'] as num).toDouble(),
      characterErrorRate: (json['character_error_rate'] as num).toDouble(),
      phonemeErrorRate: (json['phoneme_error_rate'] as num).toDouble(),
      averageWordDuration: (json['average_word_duration'] as num).toDouble(),
      averagePhonemesDuration: (json['average_phoneme_duration'] as num)
          .toDouble(),
      timingPrecision: (json['timing_precision'] as num).toDouble(),
      correctlyPronouncedPhonemes: json['correctly_pronounced_phonemes'] as int,
      totalPhonemes: json['total_phonemes'] as int,
      phonemeAccuracyPercentage: json['phoneme_accuracy_percentage'] as int,
      speakingSpeed: (json['speaking_speed'] as num).toDouble(),
      pausePatternsScore: json['pause_patterns_score'] as int,
      rhythmScore: json['rhythm_score'] as int,
      confidenceDistribution: ConfidenceDistribution.fromJson(
        json['confidence_distribution'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word_error_rate': wordErrorRate,
      'character_error_rate': characterErrorRate,
      'phoneme_error_rate': phonemeErrorRate,
      'average_word_duration': averageWordDuration,
      'average_phoneme_duration': averagePhonemesDuration,
      'timing_precision': timingPrecision,
      'correctly_pronounced_phonemes': correctlyPronouncedPhonemes,
      'total_phonemes': totalPhonemes,
      'phoneme_accuracy_percentage': phonemeAccuracyPercentage,
      'speaking_speed': speakingSpeed,
      'pause_patterns_score': pausePatternsScore,
      'rhythm_score': rhythmScore,
      'confidence_distribution': confidenceDistribution.toJson(),
    };
  }
}

class ConfidenceDistribution {
  final double high;
  final double medium;
  final double low;

  ConfidenceDistribution({
    required this.high,
    required this.medium,
    required this.low,
  });

  factory ConfidenceDistribution.fromJson(Map<String, dynamic> json) {
    return ConfidenceDistribution(
      high: (json['high'] as num).toDouble(),
      medium: (json['medium'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'high': high, 'medium': medium, 'low': low};
  }
}

class PronunciationFeedback {
  final String overallFeedback;
  final List<String> strengths;
  final List<String> areasForImprovement;
  final List<String> specificPhonemeFeedback;
  final List<String> practiceSuggestions;
  final String difficultyLevelRecommendation;
  final String confidenceLevel;

  PronunciationFeedback({
    required this.overallFeedback,
    required this.strengths,
    required this.areasForImprovement,
    required this.specificPhonemeFeedback,
    required this.practiceSuggestions,
    required this.difficultyLevelRecommendation,
    required this.confidenceLevel,
  });

  factory PronunciationFeedback.fromJson(Map<String, dynamic> json) {
    return PronunciationFeedback(
      overallFeedback: json['overall_feedback'] as String,
      strengths: (json['strengths'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      areasForImprovement: (json['areas_for_improvement'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      specificPhonemeFeedback:
          (json['specific_phoneme_feedback'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      practiceSuggestions: (json['practice_suggestions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      difficultyLevelRecommendation:
          json['difficulty_level_recommendation'] as String,
      confidenceLevel: json['confidence_level'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overall_feedback': overallFeedback,
      'strengths': strengths,
      'areas_for_improvement': areasForImprovement,
      'specific_phoneme_feedback': specificPhonemeFeedback,
      'practice_suggestions': practiceSuggestions,
      'difficulty_level_recommendation': difficultyLevelRecommendation,
      'confidence_level': confidenceLevel,
    };
  }
}
