class VowelProgressModel {
  final String vowelId;
  final String symbol;
  final String name;
  final int totalLessons;
  final int completedLessons;
  final int progressPercentage;
  final int currentMasteryLevel;
  final String? lastReview;

  VowelProgressModel({
    required this.vowelId,
    required this.symbol,
    required this.name,
    required this.totalLessons,
    required this.completedLessons,
    required this.progressPercentage,
    required this.currentMasteryLevel,
    this.lastReview,
  });

  factory VowelProgressModel.fromJson(Map<String, dynamic> json) {
    return VowelProgressModel(
      vowelId: json['vowelId'] ?? '',
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      totalLessons: json['totalLessons'] ?? 0,
      completedLessons: json['completedLessons'] ?? 0,
      progressPercentage: json['progressPercentage'] ?? 0,
      currentMasteryLevel: json['currentMasteryLevel'] ?? 0,
      lastReview: json['lastReview'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vowelId': vowelId,
      'symbol': symbol,
      'name': name,
      'totalLessons': totalLessons,
      'completedLessons': completedLessons,
      'progressPercentage': progressPercentage,
      'currentMasteryLevel': currentMasteryLevel,
      if (lastReview != null) 'lastReview': lastReview,
    };
  }

  VowelProgressModel copyWith({
    String? vowelId,
    String? symbol,
    String? name,
    int? totalLessons,
    int? completedLessons,
    int? progressPercentage,
    int? currentMasteryLevel,
    String? lastReview,
  }) {
    return VowelProgressModel(
      vowelId: vowelId ?? this.vowelId,
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
    return other is VowelProgressModel &&
        other.vowelId == vowelId &&
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
    return vowelId.hashCode ^
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
    return 'VowelProgressModel(vowelId: $vowelId, symbol: $symbol, name: $name, totalLessons: $totalLessons, completedLessons: $completedLessons, progressPercentage: $progressPercentage, currentMasteryLevel: $currentMasteryLevel, lastReview: $lastReview)';
  }
}
