import 'package:vocabu_rex_mobile/auth/domain/repositories/auth_repository.dart';

class RegisterUsercase {
  final AuthRepository authRepository;
  RegisterUsercase({required this.authRepository});
  Future<void> call(String email, String password) async {
    await authRepository.register(email, password);
  }
}
