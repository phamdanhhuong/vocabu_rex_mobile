import 'exercise_meta_entity.dart';

class ExerciseEntity {
  final String id;
  final String lessonId;
  final String exerciseType;
  final String? prompt;
  final ExerciseMetaEntity? meta;
  final int position;
  final DateTime createdAt;
  final bool isInteractive;
  final bool isContentBased;

  ExerciseEntity({
    required this.id,
    required this.lessonId,
    required this.exerciseType,
    this.prompt,
    this.meta,
    required this.position,
    required this.createdAt,
    required this.isInteractive,
    required this.isContentBased,
  });

  factory ExerciseEntity.fromModel(dynamic model) {
    ExerciseMetaEntity? metaEntity;
    if (model.meta != null) {
      final exerciseType = model.exerciseType is String
          ? model.exerciseType
          : model.exerciseType.value;
      metaEntity = ExerciseMetaEntity.fromJson(
        Map<String, dynamic>.from(model.meta),
        exerciseType,
      );
    }

    return ExerciseEntity(
      id: model.id,
      lessonId: model.lessonId,
      exerciseType: model.exerciseType is String
          ? model.exerciseType
          : model.exerciseType.value,
      prompt: model.prompt,
      meta: metaEntity,
      position: model.position,
      createdAt: model.createdAt,
      isInteractive: model.isInteractive,
      isContentBased: model.isContentBased,
    );
  }

  // Convenience factory methods for specific exercise types
  factory ExerciseEntity.listenChoose({
    required String id,
    required String lessonId,
    required String prompt,
    required int position,
    required DateTime createdAt,
    required bool isInteractive,
    required bool isContentBased,
    required ListenChooseMetaEntity meta,
  }) {
    return ExerciseEntity(
      id: id,
      lessonId: lessonId,
      exerciseType: 'listen_choose',
      prompt: prompt,
      meta: meta,
      position: position,
      createdAt: createdAt,
      isInteractive: isInteractive,
      isContentBased: isContentBased,
    );
  }

  factory ExerciseEntity.multipleChoice({
    required String id,
    required String lessonId,
    required String prompt,
    required int position,
    required DateTime createdAt,
    required bool isInteractive,
    required bool isContentBased,
    required MultipleChoiceMetaEntity meta,
  }) {
    return ExerciseEntity(
      id: id,
      lessonId: lessonId,
      exerciseType: 'multiple_choice',
      prompt: prompt,
      meta: meta,
      position: position,
      createdAt: createdAt,
      isInteractive: isInteractive,
      isContentBased: isContentBased,
    );
  }

  factory ExerciseEntity.translate({
    required String id,
    required String lessonId,
    required String prompt,
    required int position,
    required DateTime createdAt,
    required bool isInteractive,
    required bool isContentBased,
    required TranslateMetaEntity meta,
  }) {
    return ExerciseEntity(
      id: id,
      lessonId: lessonId,
      exerciseType: 'translate',
      prompt: prompt,
      meta: meta,
      position: position,
      createdAt: createdAt,
      isInteractive: isInteractive,
      isContentBased: isContentBased,
    );
  }

  factory ExerciseEntity.fillBlank({
    required String id,
    required String lessonId,
    required String prompt,
    required int position,
    required DateTime createdAt,
    required bool isInteractive,
    required bool isContentBased,
    required FillBlankMetaEntity meta,
  }) {
    return ExerciseEntity(
      id: id,
      lessonId: lessonId,
      exerciseType: 'fill_blank',
      prompt: prompt,
      meta: meta,
      position: position,
      createdAt: createdAt,
      isInteractive: isInteractive,
      isContentBased: isContentBased,
    );
  }

  // Business logic methods can be added here
  bool get requiresUserInput => isInteractive;

  bool get hasTextContent => prompt != null && prompt!.isNotEmpty;

  bool get hasMetadata => meta != null;

  // Type-safe meta getters
  ListenChooseMetaEntity? get listenChooseMeta {
    return meta is ListenChooseMetaEntity
        ? meta as ListenChooseMetaEntity
        : null;
  }

  MultipleChoiceMetaEntity? get multipleChoiceMeta {
    return meta is MultipleChoiceMetaEntity
        ? meta as MultipleChoiceMetaEntity
        : null;
  }

  TranslateMetaEntity? get translateMeta {
    return meta is TranslateMetaEntity ? meta as TranslateMetaEntity : null;
  }

  FillBlankMetaEntity? get fillBlankMeta {
    return meta is FillBlankMetaEntity ? meta as FillBlankMetaEntity : null;
  }

  MatchMetaEntity? get matchMeta {
    return meta is MatchMetaEntity ? meta as MatchMetaEntity : null;
  }

  PodcastMetaEntity? get podcastMeta {
    return meta is PodcastMetaEntity ? meta as PodcastMetaEntity : null;
  }

  WritingPromptMetaEntity? get writingPromptMeta {
    return meta is WritingPromptMetaEntity
        ? meta as WritingPromptMetaEntity
        : null;
  }

  // Helper methods for common exercise operations
  bool get hasAudio {
    return listenChooseMeta?.audioUrl != null || podcastMeta?.audioUrl != null;
  }

  String? get audioUrl {
    return listenChooseMeta?.audioUrl ?? podcastMeta?.audioUrl;
  }

  bool get hasOptions {
    return listenChooseMeta?.options.isNotEmpty == true ||
        multipleChoiceMeta?.options.isNotEmpty == true;
  }

  List<String>? get options {
    return listenChooseMeta?.options ?? multipleChoiceMeta?.options;
  }

  String? get correctAnswer {
    return listenChooseMeta?.correctAnswer ??
        multipleChoiceMeta?.correctAnswer ??
        translateMeta?.correctAnswer ??
        fillBlankMeta?.correctAnswer;
  }

  ExerciseEntity copyWith({
    String? id,
    String? lessonId,
    String? exerciseType,
    String? prompt,
    ExerciseMetaEntity? meta,
    int? position,
    DateTime? createdAt,
    bool? isInteractive,
    bool? isContentBased,
  }) {
    return ExerciseEntity(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      exerciseType: exerciseType ?? this.exerciseType,
      prompt: prompt ?? this.prompt,
      meta: meta ?? this.meta,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      isInteractive: isInteractive ?? this.isInteractive,
      isContentBased: isContentBased ?? this.isContentBased,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          lessonId == other.lessonId &&
          exerciseType == other.exerciseType &&
          prompt == other.prompt &&
          position == other.position &&
          createdAt == other.createdAt &&
          isInteractive == other.isInteractive &&
          isContentBased == other.isContentBased;

  @override
  int get hashCode =>
      id.hashCode ^
      lessonId.hashCode ^
      exerciseType.hashCode ^
      prompt.hashCode ^
      position.hashCode ^
      createdAt.hashCode ^
      isInteractive.hashCode ^
      isContentBased.hashCode;

  // Serialization methods
  Map<String, dynamic>? get metaAsJson => meta?.toJson();

  @override
  String toString() {
    return 'ExerciseEntity{id: $id, lessonId: $lessonId, exerciseType: $exerciseType, position: $position, isInteractive: $isInteractive, isContentBased: $isContentBased}';
  }
}
