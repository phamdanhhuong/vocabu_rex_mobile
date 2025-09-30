import 'package:vocabu_rex_mobile/auth/data/models/user_model.dart';

abstract class AuthDataSource {
  Future<String> register(
    String email,
    String password,
    String fullName,
    String gender,
    DateTime birth,
  );
  Future<AuthResponseModel> login(String email, String password);
  Future<void> verifyOtp(String userId, String otp);
}
