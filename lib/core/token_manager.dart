import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vocabu_rex_mobile/network/dio_client.dart';
import 'package:vocabu_rex_mobile/network/interceptors/auth_interceptor.dart';

class TokenManager {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _biometricsEnabledKey = 'biometrics_enabled';

  // Secure storage cho refresh token (chỉ dùng trên mobile)
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Key cho web fallback (dùng shared_preferences thay vì secure storage)
  static const String _refreshTokenWebKey = 'refresh_token_web';

  // Lưu access token
  static Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);

    // Set token cho AuthInterceptor
    try {
      final dioClient = DioClient.getInstance();
      final authInterceptors = dioClient.dio.interceptors
          .whereType<AuthInterceptor>();
      if (authInterceptors.isNotEmpty) {
        authInterceptors.first.setAccessToken(token);
      }
    } catch (e) {
      // Ignore error nếu DioClient chưa được khởi tạo
    }
  }

  // Lấy access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Lưu refresh token (secure storage trên mobile, shared_preferences trên web)
  static Future<void> saveRefreshToken(String token) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_refreshTokenWebKey, token);
    } else {
      await _secureStorage.write(key: _refreshTokenKey, value: token);
    }
  }

  // Lấy refresh token
  static Future<String?> getRefreshToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshTokenWebKey);
    }
    return await _secureStorage.read(key: _refreshTokenKey);
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
    try {
      final dioClient = DioClient.getInstance();
      final authInterceptors = dioClient.dio.interceptors
          .whereType<AuthInterceptor>();
      if (authInterceptors.isNotEmpty) {
        authInterceptors.first.clearAccessToken();
      }
    } catch (e) {
      // Ignore error nếu DioClient chưa được khởi tạo
    }
  }

  // Xóa tất cả thông tin đăng nhập
  static Future<void> clearAllTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final futures = <Future>[
      prefs.remove(_accessTokenKey),
      prefs.remove(_userIdKey),
      prefs.remove(_userEmailKey),
      prefs.remove(_biometricsEnabledKey),
    ];

    if (kIsWeb) {
      futures.add(prefs.remove(_refreshTokenWebKey));
    } else {
      futures.add(_secureStorage.delete(key: _refreshTokenKey));
    }

    await Future.wait(futures);

    // Clear token từ AuthInterceptor
    try {
      final dioClient = DioClient.getInstance();
      final authInterceptors = dioClient.dio.interceptors
          .whereType<AuthInterceptor>();
      if (authInterceptors.isNotEmpty) {
        authInterceptors.first.clearAccessToken();
      }
    } catch (e) {
      // Ignore error nếu DioClient chưa được khởi tạo
    }
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
      try {
        final dioClient = DioClient.getInstance();
        final authInterceptors = dioClient.dio.interceptors
            .whereType<AuthInterceptor>();
        if (authInterceptors.isNotEmpty) {
          authInterceptors.first.setAccessToken(token);
        }
      } catch (e) {
        // Ignore error nếu DioClient chưa được khởi tạo
      }
    }
  }

  // ============= BIOMETRIC AUTHENTICATION =============
  
  // Bật/tắt đăng nhập sinh trắc học
  static Future<void> setBiometricsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricsEnabledKey, enabled);
  }

  // Kiểm tra sinh trắc học có được bật không
  static Future<bool> isBiometricsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricsEnabledKey) ?? false;
  }

  // Lưu thông tin đăng nhập với tùy chọn sinh trắc học
  static Future<void> saveLoginInfoWithBiometrics({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String email,
    bool enableBiometrics = false,
  }) async {
    await saveLoginInfo(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
      email: email,
    );
    
    if (enableBiometrics) {
      await setBiometricsEnabled(true);
    }
  }
}
