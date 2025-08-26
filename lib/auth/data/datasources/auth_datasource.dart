import 'package:vocabu_rex_mobile/auth/data/models/user_model.dart';

abstract class AuthDataSource {
  Future<void> register(String email, String password);
  Future<AuthResponseModel> login(String email, String password);
}
