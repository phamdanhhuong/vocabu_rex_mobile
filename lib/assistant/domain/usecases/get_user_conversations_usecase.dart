import 'package:vocabu_rex_mobile/assistant/domain/entities/entities.dart';
import 'package:vocabu_rex_mobile/assistant/domain/repositories/assistant_repository.dart';

class GetUserConversationsUsecase {
  final AssistantRepository repository;

  GetUserConversationsUsecase({required this.repository});

  Future<List<ConversationEntity>> call() {
    return repository.getUserConversations();
  }
}
