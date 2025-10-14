import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vocabu_rex_mobile/core/token_manager.dart';
import 'package:vocabu_rex_mobile/network/api_constants.dart';
import 'package:vocabu_rex_mobile/network/dio_client.dart';

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
  Future<String?> refreshTokenApi(String refreshToken) async {
    try {
      final dioClient = DioClient.getInstance();
      final response = await dioClient.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
        options: Options(headers: {
          'Content-Type': ApiHeaders.applicationJson,
          'Accept': ApiHeaders.applicationJson,
        }),
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data['accessToken'] as String?;
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
          final newToken = await refreshTokenApi(refreshToken);
          if (newToken != null) {
            setAccessToken(newToken);
            // Retry lại request với token mới
            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newToken';
            final cloneReq = await Dio().fetch(opts);
            return handler.resolve(cloneReq);
          } else {
            // Refresh thất bại, chuyển hướng đăng nhập
            if (onRequireLogin != null) onRequireLogin!();
          }
        } catch (e) {
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
