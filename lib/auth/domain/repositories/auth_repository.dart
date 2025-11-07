import 'package:vocabu_rex_mobile/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<String> register(Map<String, dynamic> userData);
  Future<UserEntity?> login(String email, String password);
  Future<UserEntity?> googleLogin(String idToken);
  Future<Map<String, dynamic>> verifyOtp(String userId, String otp);
}
