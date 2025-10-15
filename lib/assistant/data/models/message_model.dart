class MessageModel {
  final String messageId;
  final String conversationId;
  final String role;
  final String content;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  MessageModel({
    required this.messageId,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.timestamp,
    required this.metadata,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageId: json['message_id'] as String? ?? '',
      conversationId: json['conversation_id'] as String? ?? '',
      role: json['role'] as String? ?? '',
      content: json['content'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'conversation_id': conversationId,
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  MessageModel copyWith({
    String? messageId,
    String? conversationId,
    String? role,
    String? content,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return MessageModel(
      messageId: messageId ?? this.messageId,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'MessageModel(messageId: $messageId, conversationId: $conversationId, role: $role, content: $content, timestamp: $timestamp, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageModel &&
        other.messageId == messageId &&
        other.conversationId == conversationId &&
        other.role == role &&
        other.content == content &&
        other.timestamp == timestamp &&
        _mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode {
    return messageId.hashCode ^
        conversationId.hashCode ^
        role.hashCode ^
        content.hashCode ^
        timestamp.hashCode ^
        metadata.hashCode;
  }

  bool _mapEquals(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    if (map1.length != map2.length) return false;
    for (var key in map1.keys) {
      if (!map2.containsKey(key) || map1[key] != map2[key]) return false;
    }
    return true;
  }
}
