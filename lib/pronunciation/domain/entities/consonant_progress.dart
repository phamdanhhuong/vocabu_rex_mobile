class ConsonantProgress {
  final String consonantId;
  final String symbol;
  final String name;
  final int totalLessons;
  final int completedLessons;
  final int progressPercentage;
  final int currentMasteryLevel;
  final DateTime? lastReview;

  const ConsonantProgress({
    required this.consonantId,
    required this.symbol,
    required this.name,
    required this.totalLessons,
    required this.completedLessons,
    required this.progressPercentage,
    required this.currentMasteryLevel,
    this.lastReview,
  });

  factory ConsonantProgress.fromModel(dynamic model) {
    return ConsonantProgress(
      consonantId: model.consonantId,
      symbol: model.symbol,
      name: model.name,
      totalLessons: model.totalLessons,
      completedLessons: model.completedLessons,
      progressPercentage: model.progressPercentage,
      currentMasteryLevel: model.currentMasteryLevel,
      lastReview: model.lastReview != null
          ? DateTime.tryParse(model.lastReview!)
          : null,
    );
  }

  ConsonantProgress copyWith({
    String? consonantId,
    String? symbol,
    String? name,
    int? totalLessons,
    int? completedLessons,
    int? progressPercentage,
    int? currentMasteryLevel,
    DateTime? lastReview,
  }) {
    return ConsonantProgress(
      consonantId: consonantId ?? this.consonantId,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      totalLessons: totalLessons ?? this.totalLessons,
      completedLessons: completedLessons ?? this.completedLessons,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      currentMasteryLevel: currentMasteryLevel ?? this.currentMasteryLevel,
      lastReview: lastReview ?? this.lastReview,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConsonantProgress &&
        other.consonantId == consonantId &&
        other.symbol == symbol &&
        other.name == name &&
        other.totalLessons == totalLessons &&
        other.completedLessons == completedLessons &&
        other.progressPercentage == progressPercentage &&
        other.currentMasteryLevel == currentMasteryLevel &&
        other.lastReview == lastReview;
  }

  @override
  int get hashCode {
    return consonantId.hashCode ^
        symbol.hashCode ^
        name.hashCode ^
        totalLessons.hashCode ^
        completedLessons.hashCode ^
        progressPercentage.hashCode ^
        currentMasteryLevel.hashCode ^
        lastReview.hashCode;
  }

  @override
  String toString() {
    return 'ConsonantProgress(consonantId: $consonantId, symbol: $symbol, name: $name, totalLessons: $totalLessons, completedLessons: $completedLessons, progressPercentage: $progressPercentage, currentMasteryLevel: $currentMasteryLevel, lastReview: $lastReview)';
  }

  // Business logic methods
  bool get isCompleted => progressPercentage == 100;
  bool get isInProgress => progressPercentage > 0 && progressPercentage < 100;
  bool get isNotStarted => progressPercentage == 0;

  double get completionRate =>
      totalLessons > 0 ? (completedLessons / totalLessons) : 0.0;

  bool get needsReview {
    if (lastReview == null || !isCompleted) return false;
    final daysSinceReview = DateTime.now().difference(lastReview!).inDays;
    return daysSinceReview > 7; // Review if not practiced for 7 days
  }
}
