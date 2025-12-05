import 'package:vocabu_rex_mobile/assistant/data/datasources/chat_datasource.dart';
import 'package:vocabu_rex_mobile/assistant/domain/entities/message_entity.dart';
import 'package:vocabu_rex_mobile/assistant/domain/entities/conversation_entity.dart';
import 'package:vocabu_rex_mobile/assistant/domain/repositories/assistant_repository.dart';

class AssistantRepositoryImpl implements AssistantRepository {
  final ChatDatasource datasource;

  AssistantRepositoryImpl({required this.datasource});

  @override
  Future<MessageEntity> chat(String conversationId, String message, {String? role}) async {
    final model = await datasource.chat(conversationId, message, role: role);
    return MessageEntity.fromModel(model);
  }

  @override
  Future<String> startChat() async {
    final model = await datasource.startChat();
    return model.id;
  }

  @override
  Future<List<ConversationEntity>> getUserConversations() async {
    final models = await datasource.getUserConversations();
    return models.map((model) => ConversationEntity.fromModel(model)).toList();
  }

  @override
  Future<List<MessageEntity>> getConversationMessages(String conversationId) async {
    final models = await datasource.getConversationMessages(conversationId);
    return models.map((model) => MessageEntity.fromModel(model)).toList();
  }
}
