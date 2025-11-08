import 'package:vocabu_rex_mobile/auth/domain/entities/user_entity.dart';
import 'package:vocabu_rex_mobile/auth/domain/repositories/auth_repository.dart';
import 'package:vocabu_rex_mobile/core/biometric_service.dart';
import 'package:vocabu_rex_mobile/core/token_manager.dart';

class BiometricLoginUsecase {
  final AuthRepository authRepository;

  BiometricLoginUsecase({required this.authRepository});

  // Kiểm tra có thể dùng đăng nhập sinh trắc học không
  Future<bool> canUseBiometricLogin() async {
    // Kiểm tra thiết bị có hỗ trợ sinh trắc học
    final isAvailable = await BiometricService.isBiometricAvailable();
    if (!isAvailable) return false;

    // Kiểm tra người dùng đã bật tính năng này chưa
    final isEnabled = await TokenManager.isBiometricsEnabled();
    if (!isEnabled) return false;

    // Kiểm tra có refresh token không
    final refreshToken = await TokenManager.getRefreshToken();
    return refreshToken != null && refreshToken.isNotEmpty;
  }

  // Thực hiện đăng nhập sinh trắc học
  Future<BiometricLoginResult> execute() async {
    try {
      // 1. Kiểm tra điều kiện
      final canUse = await canUseBiometricLogin();
      if (!canUse) {
        return BiometricLoginResult(
          success: false,
          message: 'Không thể sử dụng đăng nhập sinh trắc học',
        );
      }

      // 2. Xác thực sinh trắc học
      final authResult = await BiometricService.authenticate(
        reason: 'Xác thực để đăng nhập vào Vocaburex',
      );

      if (authResult != BiometricAuthResult.success) {
        return BiometricLoginResult(
          success: false,
          message: _getErrorMessage(authResult),
        );
      }

      // 3. Lấy refresh token từ secure storage
      final refreshToken = await TokenManager.getRefreshToken();
      if (refreshToken == null) {
        return BiometricLoginResult(
          success: false,
          message: 'Không tìm thấy thông tin đăng nhập',
        );
      }

      // 4. Gọi API refresh token để lấy access token mới
      final user = await authRepository.refreshToken(refreshToken);
      
      if (user == null) {
        return BiometricLoginResult(
          success: false,
          message: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại',
        );
      }

      return BiometricLoginResult(
        success: true,
        user: user,
        message: 'Đăng nhập thành công',
      );
    } catch (e) {
      print('Biometric login error: $e');
      return BiometricLoginResult(
        success: false,
        message: 'Đăng nhập thất bại: ${e.toString()}',
      );
    }
  }

  String _getErrorMessage(BiometricAuthResult result) {
    switch (result) {
      case BiometricAuthResult.failed:
        return 'Xác thực thất bại';
      case BiometricAuthResult.notSupported:
        return 'Thiết bị không hỗ trợ sinh trắc học';
      case BiometricAuthResult.notAvailable:
        return 'Tính năng sinh trắc học không khả dụng';
      case BiometricAuthResult.notEnrolled:
        return 'Chưa đăng ký sinh trắc học trên thiết bị';
      case BiometricAuthResult.lockedOut:
        return 'Đã bị khóa do nhập sai nhiều lần';
      default:
        return 'Xác thực thất bại';
    }
  }
}

class BiometricLoginResult {
  final bool success;
  final UserEntity? user;
  final String message;

  BiometricLoginResult({
    required this.success,
    this.user,
    required this.message,
  });
}
