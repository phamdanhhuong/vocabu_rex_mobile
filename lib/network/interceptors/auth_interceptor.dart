import 'package:dio/dio.dart';

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

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Xử lý lỗi 401 (Unauthorized)
    if (err.response?.statusCode == 401) {
      // Token có thể đã hết hạn, xóa token hiện tại
      clearAccessToken();

      // Có thể thêm logic để refresh token hoặc chuyển hướng đến màn hình đăng nhập
      // Ví dụ: gọi callback để thông báo cần đăng nhập lại
    }

    super.onError(err, handler);
  }
}
