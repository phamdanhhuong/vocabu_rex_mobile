import 'package:vocabu_rex_mobile/network/base_api_service.dart';

class AssistantService extends BaseApiService {
  // Singleton pattern
  static final AssistantService _instance = AssistantService._internal();
  factory AssistantService() => _instance;
  AssistantService._internal();
}
