import 'package:vocabu_rex_mobile/assistant/data/datasources/chat_datasource.dart';
import 'package:vocabu_rex_mobile/assistant/data/models/conversation_model.dart';
import 'package:vocabu_rex_mobile/assistant/data/models/message_model.dart';
import 'package:vocabu_rex_mobile/assistant/data/services/assistant_service.dart';

class ChatDatasourceImpl implements ChatDatasource {
  final AssistantService assistantService;

  ChatDatasourceImpl({required this.assistantService});

  @override
  Future<MessageModel> chat(String conversationId, String message) async {
    final res = await assistantService.chat(
      conversationId: conversationId,
      message: message,
    );
    return MessageModel.fromJson(res);
  }

  @override
  Future<ConversationModel> startChat() async {
    final res = await assistantService.start();
    return ConversationModel.fromJson(res);
  }
}
