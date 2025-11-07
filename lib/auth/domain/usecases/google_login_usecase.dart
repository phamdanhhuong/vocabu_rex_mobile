import 'package:vocabu_rex_mobile/auth/domain/entities/user_entity.dart';
import 'package:vocabu_rex_mobile/auth/domain/repositories/auth_repository.dart';

class GoogleLoginUsecase {
  final AuthRepository authRepository;
  
  GoogleLoginUsecase({required this.authRepository});
  
  Future<UserEntity?> call(String idToken) async {
    return await authRepository.googleLogin(idToken);
  }
}
