import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabu_rex_mobile/network/dio_client.dart';
import 'package:vocabu_rex_mobile/network/interceptors/auth_interceptor.dart';

class TokenManager {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';

  // Lưu access token
  static Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);

    // Set token cho AuthInterceptor
    final dioClient = DioClient.getInstance();
    final authInterceptor = dioClient.dio.interceptors
        .whereType<AuthInterceptor>()
        .first;
    authInterceptor.setAccessToken(token);
  }

  // Lấy access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Lưu refresh token
  static Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  // Lấy refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // Lưu thông tin user
  static Future<void> saveUserInfo(String userId, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userEmailKey, email);
  }

  // Lấy thông tin user
  static Future<Map<String, String?>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString(_userIdKey),
      'email': prefs.getString(_userEmailKey),
    };
  }

  // Lưu tất cả thông tin đăng nhập
  static Future<void> saveLoginInfo({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String email,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
      saveUserInfo(userId, email),
    ]);
  }

  // Xóa access token
  static Future<void> clearAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);

    // Clear token từ AuthInterceptor
    final dioClient = DioClient.getInstance();
    final authInterceptor = dioClient.dio.interceptors
        .whereType<AuthInterceptor>()
        .first;
    authInterceptor.clearAccessToken();
  }

  // Xóa tất cả thông tin đăng nhập
  static Future<void> clearAllTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_accessTokenKey),
      prefs.remove(_refreshTokenKey),
      prefs.remove(_userIdKey),
      prefs.remove(_userEmailKey),
    ]);

    // Clear token từ AuthInterceptor
    final dioClient = DioClient.getInstance();
    final authInterceptor = dioClient.dio.interceptors
        .whereType<AuthInterceptor>()
        .first;
    authInterceptor.clearAccessToken();
  }

  // Kiểm tra có token hay không
  static Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // Khởi tạo token từ SharedPreferences khi app start
  static Future<void> initializeToken() async {
    final token = await getAccessToken();
    if (token != null && token.isNotEmpty) {
      final dioClient = DioClient.getInstance();
      final authInterceptor = dioClient.dio.interceptors
          .whereType<AuthInterceptor>()
          .first;
      authInterceptor.setAccessToken(token);
    }
  }
}
