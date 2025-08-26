import 'package:vocabu_rex_mobile/auth/data/datasources/auth_datasource.dart';
import 'package:vocabu_rex_mobile/auth/data/models/user_model.dart';
import 'package:vocabu_rex_mobile/auth/data/services/auth_service.dart';

class AuthDataSourceImpl implements AuthDataSource {
  final AuthService authService;

  AuthDataSourceImpl(this.authService);

  @override
  Future<void> register(String email, String password) async {
    await authService.register(email: email, password: password);
  }

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    final response = await authService.login(email: email, password: password);
    final result = AuthResponseModel.fromJson(response);
    return result;
  }
}
