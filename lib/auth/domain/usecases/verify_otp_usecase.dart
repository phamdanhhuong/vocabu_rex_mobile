import 'package:vocabu_rex_mobile/auth/domain/repositories/auth_repository.dart';

class VerifyOtpUsecase {
  final AuthRepository authRepository;
  VerifyOtpUsecase({required this.authRepository});
  Future<void> call(String userId, String otp) async {
    await authRepository.verifyOtp(userId, otp);
  }
}
