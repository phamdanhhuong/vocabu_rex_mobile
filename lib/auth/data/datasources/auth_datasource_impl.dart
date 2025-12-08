import 'package:vocabu_rex_mobile/auth/data/datasources/auth_datasource.dart';
import 'package:vocabu_rex_mobile/auth/data/models/user_model.dart';
import 'package:vocabu_rex_mobile/auth/data/services/auth_service.dart';

class AuthDataSourceImpl implements AuthDataSource {
  final AuthService authService;

  AuthDataSourceImpl(this.authService);

  @override
  Future<String> register(Map<String, dynamic> userData) async {
    final response = await authService.register(userData);
    return response["userId"] as String;
  }

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    final response = await authService.login(email: email, password: password);
    final result = AuthResponseModel.fromJson(response);
    return result;
  }

  @override
  Future<AuthResponseModel> googleLogin(String idToken) async {
    final response = await authService.googleLogin(idToken: idToken);
    final result = AuthResponseModel.fromJson(response);
    return result;
  }

  @override
  Future<AuthResponseModel> facebookLogin(String accessToken) async {
    final response = await authService.facebookLogin(accessToken: accessToken);
    final result = AuthResponseModel.fromJson(response);
    return result;
  }

  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    final response = await authService.refreshToken(refreshToken);
    final result = AuthResponseModel.fromJson(response);
    return result;
  }

  @override
  Future<Map<String, dynamic>> verifyOtp(String userId, String otp) async {
    return await authService.registerComplete(userId: userId, otp: otp);
  }

  @override
  Future<Map<String, dynamic>> sendResetOtp(String email) async {
    return await authService.forgotPassword(email);
  }

  @override
  Future<Map<String, dynamic>> resetPassword({
    required String userId,
    required String otp,
    required String newPassword,
  }) async {
    return await authService.resetPasswordWithOtp(
      userId: userId,
      otp: otp,
      newPassword: newPassword,
    );
  }
}
