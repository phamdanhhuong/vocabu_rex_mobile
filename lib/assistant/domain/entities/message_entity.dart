import '../../../assistant/data/models/message_model.dart';

class MessageEntity {
  final String messageId;
  final String conversationId;
  final String role;
  final String content;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const MessageEntity({
    required this.messageId,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.timestamp,
    required this.metadata,
  });

  factory MessageEntity.fromModel(MessageModel model) {
    return MessageEntity(
      messageId: model.messageId,
      conversationId: model.conversationId,
      role: model.role,
      content: model.content,
      timestamp: model.timestamp,
      metadata: model.metadata,
    );
  }

  MessageEntity copyWith({
    String? messageId,
    String? conversationId,
    String? role,
    String? content,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return MessageEntity(
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
    return 'Message(messageId: $messageId, conversationId: $conversationId, role: $role, content: $content, timestamp: $timestamp, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageEntity &&
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
