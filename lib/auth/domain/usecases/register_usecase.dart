import 'package:vocabu_rex_mobile/auth/domain/repositories/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository authRepository;
  RegisterUsecase({required this.authRepository});
  
  Future<String> call(Map<String, dynamic> userData) async {
    return await authRepository.register(
      userData['email'] ?? '',
      userData['password'] ?? '',
      userData['fullName'] ?? '',
      userData['gender'] ?? 'PREFER_NOT_TO_SAY',
      userData['dateOfBirth'] ?? DateTime.now().subtract(Duration(days: 365 * 20)), // Default 20 years old
    );
  }
}
