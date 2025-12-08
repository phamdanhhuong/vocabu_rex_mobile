import 'package:vocabu_rex_mobile/auth/domain/repositories/auth_repository.dart';

class SendResetOtpUsecase {
  final AuthRepository authRepository;

  SendResetOtpUsecase({required this.authRepository});

  Future<Map<String, dynamic>> call(String email) async {
    return await authRepository.sendResetOtp(email);
  }
}
