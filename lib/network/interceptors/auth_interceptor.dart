import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vocabu_rex_mobile/core/token_manager.dart';
import 'package:vocabu_rex_mobile/network/api_constants.dart';

class AuthInterceptor extends Interceptor {
  String? _accessToken;

  // Setter cho access token
  void setAccessToken(String token) {
    _accessToken = token;
  }

  // Getter cho access token
  String? get accessToken => _accessToken;

  // Xóa access token
  void clearAccessToken() {
    _accessToken = null;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Thêm Authorization header nếu có access token
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $_accessToken';
    }

    super.onRequest(options, handler);
  }

  // Callback khi cần chuyển hướng đăng nhập
  VoidCallback? onRequireLogin;

  // Hàm lấy refresh token
  Future<String?> getRefreshToken() async {
    return await TokenManager.getRefreshToken();
  }

  // Hàm gọi API refresh token
  Future<Map<String, String?>?> refreshTokenApi(String refreshToken) async {
    try {
      // Tạo Dio instance mới để tránh infinite loop
      final dio = Dio();
      final response = await dio.post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.refreshToken}',
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {
            'Content-Type': ApiHeaders.applicationJson,
            'Accept': ApiHeaders.applicationJson,
          },
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        return {
          'accessToken': response.data['accessToken'] as String?,
          'refreshToken': response.data['refreshToken'] as String?,
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      clearAccessToken();
      final refreshToken = await getRefreshToken();
      if (refreshToken != null) {
        try {
          final tokenResult = await refreshTokenApi(refreshToken);
          if (tokenResult != null && tokenResult['accessToken'] != null) {
            final newAccessToken = tokenResult['accessToken']!;
            final newRefreshToken = tokenResult['refreshToken'];

            // Cập nhật tokens vào TokenManager
            await TokenManager.saveAccessToken(newAccessToken);
            if (newRefreshToken != null) {
              await TokenManager.saveRefreshToken(newRefreshToken);
            }

            // Retry lại request với token mới
            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newAccessToken';

            // Sử dụng Dio instance từ DioClient thay vì tạo mới
            final dio = Dio();
            final cloneReq = await dio.fetch(opts);
            return handler.resolve(cloneReq);
          } else {
            // Refresh thất bại, xóa tất cả tokens và chuyển hướng đăng nhập
            await TokenManager.clearAllTokens();
            if (onRequireLogin != null) onRequireLogin!();
          }
        } catch (e) {
          // Refresh thất bại, xóa tất cả tokens và chuyển hướng đăng nhập
          await TokenManager.clearAllTokens();
          if (onRequireLogin != null) onRequireLogin!();
        }
      } else {
        // Không có refresh token, chuyển hướng đăng nhập
        if (onRequireLogin != null) onRequireLogin!();
      }
    }
    super.onError(err, handler);
  }
}
