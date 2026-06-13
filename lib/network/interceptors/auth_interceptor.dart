import 'dart:async';
import 'package:dio/dio.dart';
import 'package:vocabu_rex_mobile/core/token_manager.dart';
import 'package:vocabu_rex_mobile/core/app_navigator.dart';
import 'package:vocabu_rex_mobile/network/api_constants.dart';
import 'package:vocabu_rex_mobile/network/dio_client.dart';

class AuthInterceptor extends Interceptor {
  String? _accessToken;

  // Lock để tránh nhiều request cùng gọi refresh token đồng thời
  bool _isRefreshing = false;
  // Queue chứa các request đang chờ refresh token hoàn tất
  final List<_RetryRequest> _pendingRequests = [];

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

  // Hàm lấy refresh token
  Future<String?> getRefreshToken() async {
    return await TokenManager.getRefreshToken();
  }

  bool _shouldRedirectToLogin(RequestOptions options) {
    final path = options.path;
    return !path.contains(ApiEndpoints.login) &&
        !path.contains(ApiEndpoints.googleLogin) &&
        !path.contains(ApiEndpoints.facebookLogin) &&
        !path.contains(ApiEndpoints.register) &&
        !path.contains(ApiEndpoints.registerComplete) &&
        !path.contains(ApiEndpoints.refreshToken) &&
        !path.contains(ApiEndpoints.forgotPassword) &&
        !path.contains(ApiEndpoints.resetPassword);
  }

  Future<void> _redirectToLogin() async {
    await TokenManager.clearAllTokens();
    clearAccessToken();
    AppNavigator.goToLogin();
  }

  /// Lấy base URL thực tế từ DioClient (dùng URL từ .env)
  String _getBaseUrl() {
    try {
      return DioClient.getInstance().dio.options.baseUrl;
    } catch (e) {
      return ApiEndpoints.baseUrl;
    }
  }

  // Hàm gọi API refresh token
  Future<Map<String, String?>?> refreshTokenApi(String refreshToken) async {
    try {
      // Tạo Dio instance mới để tránh infinite loop
      final dio = Dio();
      final baseUrl = _getBaseUrl();
      final response = await dio.post(
        '$baseUrl${ApiEndpoints.refreshToken}',
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {
            'Content-Type': ApiHeaders.applicationJson,
            'Accept': ApiHeaders.applicationJson,
          },
        ),
      );
      if (response.statusCode == 200 && response.data != null) {
        // Response format: { data: { tokens: { accessToken, refreshToken } } }
        final tokens = response.data['data']?['tokens'];
        if (tokens != null) {
          return {
            'accessToken': tokens['accessToken'] as String?,
            'refreshToken': tokens['refreshToken'] as String?,
          };
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return super.onError(err, handler);
    }

    if (!_shouldRedirectToLogin(err.requestOptions)) {
      return super.onError(err, handler);
    }

    // Nếu đang refresh, đưa request vào queue chờ
    if (_isRefreshing) {
      _pendingRequests.add(_RetryRequest(err.requestOptions, handler));
      return;
    }

    // Bắt đầu refresh — lock lại
    _isRefreshing = true;

    final refreshToken = await getRefreshToken();

    if (refreshToken == null) {
      _isRefreshing = false;
      _rejectPendingRequests(err);
      await _redirectToLogin();
      return super.onError(err, handler);
    }

    try {
      final tokenResult = await refreshTokenApi(refreshToken);

      if (tokenResult != null && tokenResult['accessToken'] != null) {
        final newAccessToken = tokenResult['accessToken']!;
        final newRefreshToken = tokenResult['refreshToken'];

        // Cập nhật tokens vào TokenManager & AuthInterceptor
        await TokenManager.saveAccessToken(newAccessToken);
        setAccessToken(newAccessToken);

        if (newRefreshToken != null) {
          await TokenManager.saveRefreshToken(newRefreshToken);
        }

        _isRefreshing = false;

        // Retry request gốc (request đã trigger refresh)
        try {
          final response = await _retryRequest(
            err.requestOptions,
            newAccessToken,
          );
          handler.resolve(response);
        } catch (retryErr) {
          if (retryErr is DioException) {
            if (retryErr.response?.statusCode == 401) {
              await _redirectToLogin();
            }
            handler.reject(retryErr);
          } else {
            handler.reject(
              DioException(requestOptions: err.requestOptions, error: retryErr),
            );
          }
        }

        // Retry tất cả request trong queue
        await _retryPendingRequests(newAccessToken);
      } else {
        // Refresh thất bại
        _isRefreshing = false;
        _rejectPendingRequests(err);
        await _redirectToLogin();
        super.onError(err, handler);
      }
    } catch (e) {
      // Refresh thất bại do exception
      _isRefreshing = false;
      _rejectPendingRequests(err);
      await _redirectToLogin();
      super.onError(err, handler);
    }
  }

  /// Retry một request với access token mới
  Future<Response> _retryRequest(
    RequestOptions options,
    String newAccessToken,
  ) async {
    options.headers['Authorization'] = 'Bearer $newAccessToken';
    final dio = Dio(
      BaseOptions(
        baseUrl: options.baseUrl,
        connectTimeout: options.connectTimeout,
        receiveTimeout: options.receiveTimeout,
      ),
    );
    return await dio.fetch(options);
  }

  /// Retry tất cả request đang chờ trong queue
  Future<void> _retryPendingRequests(String newAccessToken) async {
    final requests = List<_RetryRequest>.from(_pendingRequests);
    _pendingRequests.clear();

    for (final request in requests) {
      try {
        final response = await _retryRequest(request.options, newAccessToken);
        request.handler.resolve(response);
      } catch (error) {
        if (error is DioException) {
          if (error.response?.statusCode == 401) {
            unawaited(_redirectToLogin());
          }
          request.handler.reject(error);
        } else {
          request.handler.reject(
            DioException(requestOptions: request.options, error: error),
          );
        }
      }
    }
  }

  /// Reject tất cả request đang chờ khi refresh thất bại
  void _rejectPendingRequests(DioException originalError) {
    final requests = List<_RetryRequest>.from(_pendingRequests);
    _pendingRequests.clear();

    for (final request in requests) {
      request.handler.reject(
        DioException(
          requestOptions: request.options,
          response: originalError.response,
          type: originalError.type,
          error: originalError.error,
          message: originalError.message,
        ),
      );
    }
  }
}

/// Class chứa thông tin request cần retry
class _RetryRequest {
  final RequestOptions options;
  final ErrorInterceptorHandler handler;

  _RetryRequest(this.options, this.handler);
}
