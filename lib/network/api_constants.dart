class ApiEndpoints {
  // Base URLs
  static const String baseUrl =
      'http://localhost:3000'; // Thay đổi URL này theo API của bạn
  static const String apiVersion = '';

  // Authentication endpoints
  static const String login = '$apiVersion/auth/login';
  static const String register = '$apiVersion/auth/register';
  static const String logout = '$apiVersion/auth/logout';
  static const String refreshToken = '$apiVersion/auth/refresh';
  static const String forgotPassword = '$apiVersion/auth/forgot-password';
  static const String resetPassword = '$apiVersion/auth/reset-password';

  // User endpoints
  static const String profile = '$apiVersion/user/profile';
  static const String updateProfile = '$apiVersion/user/profile';
  static const String changePassword = '$apiVersion/user/change-password';
}

class ApiHeaders {
  static const String contentType = 'Content-Type';
  static const String accept = 'Accept';
  static const String authorization = 'Authorization';
  static const String applicationJson = 'application/json';
  static const String bearer = 'Bearer';
}

class ApiResponseKeys {
  static const String data = 'data';
  static const String message = 'message';
  static const String success = 'success';
  static const String error = 'error';
  static const String errors = 'errors';
  static const String statusCode = 'status_code';
  static const String pagination = 'pagination';
  static const String meta = 'meta';
}

class HttpStatus {
  static const int ok = 200;
  static const int created = 201;
  static const int accepted = 202;
  static const int noContent = 204;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int methodNotAllowed = 405;
  static const int conflict = 409;
  static const int unprocessableEntity = 422;
  static const int tooManyRequests = 429;
  static const int internalServerError = 500;
  static const int badGateway = 502;
  static const int serviceUnavailable = 503;
  static const int gatewayTimeout = 504;
}
