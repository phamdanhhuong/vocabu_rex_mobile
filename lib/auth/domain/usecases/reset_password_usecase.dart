import 'package:vocabu_rex_mobile/auth/domain/repositories/auth_repository.dart';

class ResetPasswordUsecase {
  final AuthRepository authRepository;

  ResetPasswordUsecase({required this.authRepository});

  Future<Map<String, dynamic>> call({
    required String userId,
    required String otp,
    required String newPassword,
  }) async {
    return await authRepository.resetPassword(
      userId: userId,
      otp: otp,
      newPassword: newPassword,
    );
  }
}
