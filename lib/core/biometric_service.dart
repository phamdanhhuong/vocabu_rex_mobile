import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter/services.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  // Kiểm tra thiết bị có hỗ trợ sinh trắc học không
  static Future<bool> isDeviceSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (e) {
      print('Error checking device support: $e');
      return false;
    }
  }

  // Kiểm tra có sinh trắc học nào được đăng ký không
  static Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (e) {
      print('Error checking biometrics availability: $e');
      return false;
    }
  }

  // Lấy danh sách các loại sinh trắc học có sẵn
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      print('Error getting available biometrics: $e');
      return [];
    }
  }

  // Xác thực sinh trắc học
  static Future<BiometricAuthResult> authenticate({
    String reason = 'Hãy xác thực để đăng nhập vào Vocaburex',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      // Kiểm tra thiết bị có hỗ trợ không
      final isSupported = await isDeviceSupported();
      if (!isSupported) {
        return BiometricAuthResult.notSupported;
      }

      // Kiểm tra có sinh trắc học được đăng ký không
      final canCheck = await canCheckBiometrics();
      if (!canCheck) {
        return BiometricAuthResult.notEnrolled;
      }

      // Thực hiện xác thực
      final didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: true, // Chỉ dùng sinh trắc học, không dùng PIN/Password
        ),
      );

      return didAuthenticate 
          ? BiometricAuthResult.success 
          : BiometricAuthResult.failed;
          
    } on PlatformException catch (e) {
      print('Biometric authentication error: ${e.code} - ${e.message}');
      
      if (e.code == auth_error.notAvailable) {
        return BiometricAuthResult.notAvailable;
      } else if (e.code == auth_error.notEnrolled) {
        return BiometricAuthResult.notEnrolled;
      } else if (e.code == auth_error.lockedOut || 
                 e.code == auth_error.permanentlyLockedOut) {
        return BiometricAuthResult.lockedOut;
      } else {
        return BiometricAuthResult.failed;
      }
    } catch (e) {
      print('Unexpected error during biometric authentication: $e');
      return BiometricAuthResult.failed;
    }
  }

  // Lấy tên loại sinh trắc học (cho UI)
  static Future<String> getBiometricTypeName() async {
    final biometrics = await getAvailableBiometrics();
    
    if (biometrics.isEmpty) {
      return 'Sinh trắc học';
    }
    
    if (biometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return 'Vân tay';
    } else if (biometrics.contains(BiometricType.iris)) {
      return 'Mống mắt';
    } else {
      return 'Sinh trắc học';
    }
  }

  // Kiểm tra toàn bộ (helper method)
  static Future<bool> isBiometricAvailable() async {
    final isSupported = await isDeviceSupported();
    final canCheck = await canCheckBiometrics();
    return isSupported && canCheck;
  }
}

// Enum kết quả xác thực
enum BiometricAuthResult {
  success,          // Xác thực thành công
  failed,           // Xác thực thất bại (người dùng hủy hoặc sai)
  notSupported,     // Thiết bị không hỗ trợ
  notAvailable,     // Tính năng không khả dụng
  notEnrolled,      // Chưa đăng ký sinh trắc học
  lockedOut,        // Bị khóa do nhập sai nhiều lần
}
