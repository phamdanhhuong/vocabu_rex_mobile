import 'package:vocabu_rex_mobile/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<void> register(String email, String password);
  Future<UserEntity?> login(String email, String password);
}
