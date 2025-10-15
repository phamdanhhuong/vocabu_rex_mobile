import 'package:vocabu_rex_mobile/assistant/domain/repositories/assistant_repository.dart';

class StartChatUsecase {
  final AssistantRepository repository;

  StartChatUsecase({required this.repository});

  Future<String> call() {
    return repository.startChat();
  }
}
