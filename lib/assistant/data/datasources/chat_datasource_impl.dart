import 'package:vocabu_rex_mobile/assistant/data/datasources/chat_datasource.dart';
import 'package:vocabu_rex_mobile/assistant/data/models/conversation_model.dart';
import 'package:vocabu_rex_mobile/assistant/data/models/message_model.dart';
import 'package:vocabu_rex_mobile/assistant/data/services/assistant_service.dart';

class ChatDatasourceImpl implements ChatDatasource {
  final AssistantService assistantService;

  ChatDatasourceImpl({required this.assistantService});

  @override
  Future<MessageModel> chat(String conversationId, String message, {String? role}) async {
    final res = await assistantService.chat(
      conversationId: conversationId,
      message: message,
      role: role,
    );
    return MessageModel.fromJson(res);
  }

  @override
  Future<ConversationModel> startChat() async {
    final res = await assistantService.start();
    return ConversationModel.fromJson(res);
  }

  @override
  Future<List<ConversationModel>> getUserConversations() async {
    final res = await assistantService.getUserConversations();
    return res.map((json) => ConversationModel.fromJson(json)).toList();
  }

  @override
  Future<List<MessageModel>> getConversationMessages(String conversationId) async {
    final res = await assistantService.getConversationHistory(conversationId);
    
    print('=== Parsing conversation messages ===');
    print('Response keys: ${res.keys}');
    print('Has messages key: ${res.containsKey("messages")}');
    
    // Backend returns {conversation: {...}, messages: [...]}
    final messages = res['messages'] as List<dynamic>? ?? [];
    print('Messages count: ${messages.length}');
    
    return messages.map((json) => MessageModel.fromJson(json)).toList();
  }
}
