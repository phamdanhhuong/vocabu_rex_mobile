import '../../data/models/conversation_model.dart';

class ConversationEntity {
  final String id;
  final String title;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int messageCount;
  final bool isActive;

  const ConversationEntity({
    required this.id,
    required this.title,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.messageCount,
    required this.isActive,
  });

  factory ConversationEntity.fromModel(ConversationModel model) {
    return ConversationEntity(
      id: model.id,
      title: model.title,
      userId: model.userId,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      messageCount: model.messageCount,
      isActive: model.isActive,
    );
  }

  @override
  String toString() {
    return 'ConversationEntity(id: $id, title: $title, userId: $userId, createdAt: $createdAt, updatedAt: $updatedAt, messageCount: $messageCount, isActive: $isActive)';
  }
}
