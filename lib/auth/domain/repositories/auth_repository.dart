import 'package:vocabu_rex_mobile/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<String> register(
    String email,
    String password,
    String fullName,
    String gender,
    DateTime birth,
  );
  Future<UserEntity?> login(String email, String password);
  Future<void> verifyOtp(String userId, String otp);
}
