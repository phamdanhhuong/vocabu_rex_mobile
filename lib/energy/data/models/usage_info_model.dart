class UsageInfoModel {
  final DateTime? lastUsedAt;
  final String? timeSinceLastUse;

  UsageInfoModel({
    this.lastUsedAt,
    this.timeSinceLastUse,
  });

  factory UsageInfoModel.fromJson(Map<String, dynamic> json) {
    return UsageInfoModel(
      lastUsedAt: json['lastUsedAt'] != null ? DateTime.parse(json['lastUsedAt']) : null,
      timeSinceLastUse: json['timeSinceLastUse'] as String?,
    );
  }
}
