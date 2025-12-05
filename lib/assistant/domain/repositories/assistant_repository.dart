import 'package:vocabu_rex_mobile/assistant/domain/entities/entities.dart';

abstract class AssistantRepository {
  Future<String> startChat();
  Future<MessageEntity> chat(String conversationId, String message, {String? role});
  Future<List<ConversationEntity>> getUserConversations();
  Future<List<MessageEntity>> getConversationMessages(String conversationId);
}
