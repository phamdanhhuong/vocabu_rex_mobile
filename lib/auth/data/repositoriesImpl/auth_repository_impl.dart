import 'package:vocabu_rex_mobile/auth/data/datasources/auth_datasource.dart';
import 'package:vocabu_rex_mobile/auth/domain/entities/user_entity.dart';
import 'package:vocabu_rex_mobile/auth/domain/repositories/auth_repository.dart';
import 'package:vocabu_rex_mobile/core/token_manager.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource authDataSource;
  AuthRepositoryImpl({required this.authDataSource});

  @override
  Future<void> register(String email, String password) async {
    await authDataSource.register(email, password);
  }

  @override
  Future<UserEntity?> login(String email, String password) async {
    try {
      final result = await authDataSource.login(email, password);
      final user = UserEntity.fromModel(result);
      final token = result.tokens;

      if (user.id.isNotEmpty) {
        // Lưu thông tin đăng nhập
        await TokenManager.saveLoginInfo(
          accessToken: token.accessToken,
          refreshToken: token.refreshToken,
          userId: user.id,
          email: user.email,
        );

        return user;
      }
      return null;
    } catch (e) {
      // Log error nếu cần
      rethrow;
    }
  }
}
