import 'package:vocabu_rex_mobile/auth/data/datasources/auth_datasource.dart';
import 'package:vocabu_rex_mobile/auth/domain/entities/user_entity.dart';
import 'package:vocabu_rex_mobile/auth/domain/repositories/auth_repository.dart';
import 'package:vocabu_rex_mobile/core/token_manager.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource authDataSource;
  AuthRepositoryImpl({required this.authDataSource});

  @override
  Future<String> register(Map<String, dynamic> userData) async {
    return await authDataSource.register(userData);
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

  @override
  Future<UserEntity?> googleLogin(String idToken) async {
    try {
      final result = await authDataSource.googleLogin(idToken);
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

  @override
  Future<UserEntity?> facebookLogin(String accessToken) async {
    try {
      final result = await authDataSource.facebookLogin(accessToken);
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

  @override
  Future<Map<String, dynamic>> verifyOtp(String userId, String otp) async {
    return await authDataSource.verifyOtp(userId, otp);
  }
}
