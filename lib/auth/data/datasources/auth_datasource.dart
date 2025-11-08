import 'package:vocabu_rex_mobile/auth/data/models/user_model.dart';

abstract class AuthDataSource {
  Future<String> register(Map<String, dynamic> userData);
  Future<AuthResponseModel> login(String email, String password);
  Future<AuthResponseModel> googleLogin(String idToken);
  Future<AuthResponseModel> facebookLogin(String accessToken);
  Future<AuthResponseModel> refreshToken(String refreshToken);
  Future<Map<String, dynamic>> verifyOtp(String userId, String otp);
}
