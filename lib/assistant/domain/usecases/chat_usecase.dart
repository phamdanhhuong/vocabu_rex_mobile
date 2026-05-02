import 'package:vocabu_rex_mobile/assistant/domain/entities/entities.dart';
import 'package:vocabu_rex_mobile/assistant/domain/repositories/assistant_repository.dart';

class ChatUsecase {
  final AssistantRepository repository;

  ChatUsecase({required this.repository});

  Future<MessageEntity> call(
    String conversationId,
    String message, {
    String? role,
  }) {
    return repository.chat(conversationId, message, role: role);
  }
}
