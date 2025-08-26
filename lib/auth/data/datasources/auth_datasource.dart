import 'package:vocabu_rex_mobile/auth/data/services/auth_service.dart';

abstract class AuthDataSource {
  Future<void> register(String email, String password);
}

class AuthDataSourceImpl implements AuthDataSource {
  final AuthService authService;

  AuthDataSourceImpl(this.authService);

  @override
  Future<void> register(String email, String password) async {
    await authService.register(email: email, password: password);
  }
}
