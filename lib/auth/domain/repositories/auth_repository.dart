import 'package:vocabu_rex_mobile/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<String> register(Map<String, dynamic> userData);
  Future<UserEntity?> login(String email, String password);
  Future<UserEntity?> googleLogin(String idToken);
  Future<UserEntity?> facebookLogin(String accessToken);
  Future<UserEntity?> refreshToken(String refreshToken);
  Future<Map<String, dynamic>> verifyOtp(String userId, String otp);
  Future<Map<String, dynamic>> sendResetOtp(String email);
  Future<Map<String, dynamic>> resetPassword({
    required String userId,
    required String otp,
    required String newPassword,
  });
}
