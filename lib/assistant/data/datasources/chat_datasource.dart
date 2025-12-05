import 'package:vocabu_rex_mobile/assistant/data/models/models.dart';

abstract class ChatDatasource {
  Future<ConversationModel> startChat();
  Future<MessageModel> chat(String conversationId, String message, {String? role});
  Future<List<ConversationModel>> getUserConversations();
  Future<List<MessageModel>> getConversationMessages(String conversationId);
}
