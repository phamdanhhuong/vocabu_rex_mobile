import 'package:vocabu_rex_mobile/data/datasources/auth_datasource.dart';
import 'package:vocabu_rex_mobile/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource authDataSource;
  AuthRepositoryImpl({required this.authDataSource});
  @override
  Future<void> register(String email, String password) async {
    await authDataSource.register(email, password);
  }
}
