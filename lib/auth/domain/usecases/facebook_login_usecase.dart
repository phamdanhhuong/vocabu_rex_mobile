import 'package:vocabu_rex_mobile/auth/domain/entities/user_entity.dart';
import 'package:vocabu_rex_mobile/auth/domain/repositories/auth_repository.dart';

class FacebookLoginUsecase {
  final AuthRepository authRepository;

  FacebookLoginUsecase({required this.authRepository});

  Future<UserEntity?> call(String accessToken) async {
    return await authRepository.facebookLogin(accessToken);
  }
}
