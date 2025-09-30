import 'package:vocabu_rex_mobile/auth/domain/repositories/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository authRepository;
  RegisterUsecase({required this.authRepository});
  Future<String> call(
    String email,
    String password,
    String fullName,
    String gender,
    DateTime birth,
  ) async {
    return await authRepository.register(
      email,
      password,
      fullName,
      gender,
      birth,
    );
  }
}
