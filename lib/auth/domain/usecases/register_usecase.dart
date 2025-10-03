import 'package:vocabu_rex_mobile/auth/domain/repositories/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository authRepository;
  RegisterUsecase({required this.authRepository});
  
  Future<String> call(Map<String, dynamic> userData) async {
    return await authRepository.register(userData);
  }
}
