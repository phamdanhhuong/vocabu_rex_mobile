import 'package:vocabu_rex_mobile/assistant/data/datasources/chat_datasource.dart';
import 'package:vocabu_rex_mobile/assistant/domain/entities/message_entity.dart';
import 'package:vocabu_rex_mobile/assistant/domain/repositories/assistant_repository.dart';

class AssistantRepositoryImpl implements AssistantRepository {
  final ChatDatasource datasource;

  AssistantRepositoryImpl({required this.datasource});

  @override
  Future<MessageEntity> chat(String conversationId, String message) async {
    final model = await datasource.chat(conversationId, message);
    return MessageEntity.fromModel(model);
  }

  @override
  Future<String> startChat() async {
    final model = await datasource.startChat();
    return model.id;
  }
}
