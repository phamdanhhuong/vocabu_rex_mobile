class ExerciseEntity {
  final String id;
  final String lessonId;
  final String exerciseType;
  final String? prompt;
  final Map<String, dynamic>? meta;
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
    return ExerciseEntity(
      id: model.id,
      lessonId: model.lessonId,
      exerciseType: model.exerciseType is String
          ? model.exerciseType
          : model.exerciseType.value,
      prompt: model.prompt,
      meta: model.meta,
      position: model.position,
      createdAt: model.createdAt,
      isInteractive: model.isInteractive,
      isContentBased: model.isContentBased,
    );
  }

  // Business logic methods can be added here
  bool get requiresUserInput => isInteractive;

  bool get hasTextContent => prompt != null && prompt!.isNotEmpty;

  bool get hasMetadata => meta != null && meta!.isNotEmpty;

  ExerciseEntity copyWith({
    String? id,
    String? lessonId,
    String? exerciseType,
    String? prompt,
    Map<String, dynamic>? meta,
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

  @override
  String toString() {
    return 'ExerciseEntity{id: $id, lessonId: $lessonId, exerciseType: $exerciseType, position: $position, isInteractive: $isInteractive, isContentBased: $isContentBased}';
  }
}
