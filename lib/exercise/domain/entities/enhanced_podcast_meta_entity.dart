import 'podcast_question_entity.dart';
import 'exercise_meta_entity.dart';

/// Enhanced Podcast Meta Entity with media support and new question types

enum PodcastMediaType {
  none,
  gif,
  video,
  lottie,
}

class PodcastMediaEntity {
  final PodcastMediaType type;
  final String url;
  final String? thumbnailUrl; // For video
  final bool autoPlay;
  final bool loop;

  const PodcastMediaEntity({
    required this.type,
    required this.url,
    this.thumbnailUrl,
    this.autoPlay = true,
    this.loop = true,
  });

  factory PodcastMediaEntity.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String?;
    final type = typeStr != null
        ? PodcastMediaType.values.firstWhere(
            (e) => e.toString().split('.').last == typeStr,
            orElse: () => PodcastMediaType.none,
          )
        : PodcastMediaType.none;

    return PodcastMediaEntity(
      type: type,
      url: json['url'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String?,
      autoPlay: json['autoPlay'] as bool? ?? true,
      loop: json['loop'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'url': url,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      'autoPlay': autoPlay,
      'loop': loop,
    };
  }
}

/// Enhanced Podcast Segment with new question types
class EnhancedPodcastSegment {
  final int order;
  final String transcript;
  final String voiceGender; // 'male' or 'female'
  final List<PodcastQuestionEntity>? questions; // New enhanced questions
  final int? pauseAfterMs; // Optional pause duration after this segment

  const EnhancedPodcastSegment({
    required this.order,
    required this.transcript,
    required this.voiceGender,
    this.questions,
    this.pauseAfterMs,
  });

  factory EnhancedPodcastSegment.fromJson(Map<String, dynamic> json) {
    final questionsData = json['questions'];
    List<PodcastQuestionEntity>? questionsList;
    
    if (questionsData != null && questionsData is List && questionsData.isNotEmpty) {
      questionsList = questionsData
          .map((q) => PodcastQuestionEntity.fromJson(q as Map<String, dynamic>))
          .toList();
    }
    
    return EnhancedPodcastSegment(
      order: json['order'] as int,
      transcript: json['transcript'] as String,
      voiceGender: json['voiceGender'] as String,
      questions: questionsList,
      pauseAfterMs: json['pauseAfterMs'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': order,
      'transcript': transcript,
      'voiceGender': voiceGender,
      if (questions != null)
        'questions': questions!.map((q) => q.toJson()).toList(),
      if (pauseAfterMs != null) 'pauseAfterMs': pauseAfterMs,
    };
  }
}

/// Enhanced Podcast Meta Entity
class EnhancedPodcastMetaEntity extends ExerciseMetaEntity {
  final String title;
  final String? description;
  final PodcastMediaEntity? media; // Optional media (gif/video)
  final List<EnhancedPodcastSegment> segments;
  final int? totalDurationMs; // Estimated total duration
  final bool showTranscript; // Whether to show transcript while playing

  const EnhancedPodcastMetaEntity({
    required this.title,
    this.description,
    this.media,
    required this.segments,
    this.totalDurationMs,
    this.showTranscript = false,
  });

  factory EnhancedPodcastMetaEntity.fromJson(Map<String, dynamic> json) {
    final segmentsData = json['segments'] as List;
    final mediaData = json['media'] as Map<String, dynamic>?;

    return EnhancedPodcastMetaEntity(
      title: json['title'] as String,
      description: json['description'] as String?,
      media: mediaData != null 
          ? PodcastMediaEntity.fromJson(mediaData) 
          : null,
      segments: segmentsData
          .map((s) => EnhancedPodcastSegment.fromJson(s))
          .toList(),
      totalDurationMs: json['totalDurationMs'] as int?,
      showTranscript: json['showTranscript'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (description != null) 'description': description,
      if (media != null) 'media': media!.toJson(),
      'segments': segments.map((s) => s.toJson()).toList(),
      if (totalDurationMs != null) 'totalDurationMs': totalDurationMs,
      'showTranscript': showTranscript,
    };
  }
}
