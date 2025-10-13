class UsageInfoModel {
  final DateTime lastUsedAt;
  final String timeSinceLastUse;

  UsageInfoModel({
    required this.lastUsedAt,
    required this.timeSinceLastUse,
  });

  factory UsageInfoModel.fromJson(Map<String, dynamic> json) {
    return UsageInfoModel(
      lastUsedAt: DateTime.parse(json['lastUsedAt']),
      timeSinceLastUse: json['timeSinceLastUse'] as String,
    );
  }
}
