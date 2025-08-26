import '../../../network/base_api_service.dart';
import '../../../network/api_constants.dart';
import 'package:dio/dio.dart';

class AuthService extends BaseApiService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Đăng nhập
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      return response.data;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  // Đăng ký
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.post(
        ApiEndpoints.register,
        data: {'email': email, 'password': password},
      );

      return response.data;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  // Đăng xuất
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await client.post(ApiEndpoints.logout);
      return response.data;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  // Refresh token
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await client.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      return response.data;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  // Quên mật khẩu
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await client.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );

      return response.data;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  // Reset mật khẩu
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await client.post(
        ApiEndpoints.resetPassword,
        data: {
          'email': email,
          'token': token,
          'password': password,
          'password_confirmation': confirmPassword,
        },
      );

      return response.data;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  // Lấy thông tin profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await client.get(ApiEndpoints.profile);
      return response.data;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  // Cập nhật profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;

      final response = await client.put(ApiEndpoints.updateProfile, data: data);

      return response.data;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  // Đổi mật khẩu
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await client.post(
        ApiEndpoints.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        },
      );

      return response.data;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }
}
