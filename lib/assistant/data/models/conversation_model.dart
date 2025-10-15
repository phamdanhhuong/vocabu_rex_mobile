class ConversationModel {
  final String id;
  final String title;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int messageCount;
  final bool isActive;

  ConversationModel({
    required this.id,
    required this.title,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.messageCount,
    required this.isActive,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      messageCount: json['message_count'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'message_count': messageCount,
      'is_active': isActive,
    };
  }

  ConversationModel copyWith({
    String? id,
    String? title,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? messageCount,
    bool? isActive,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messageCount: messageCount ?? this.messageCount,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'ConversationModel(id: $id, title: $title, userId: $userId, createdAt: $createdAt, updatedAt: $updatedAt, messageCount: $messageCount, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConversationModel &&
        other.id == id &&
        other.title == title &&
        other.userId == userId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.messageCount == messageCount &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        userId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        messageCount.hashCode ^
        isActive.hashCode;
  }
}
