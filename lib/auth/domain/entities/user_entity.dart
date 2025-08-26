import 'package:vocabu_rex_mobile/auth/data/models/user_model.dart';

class UserEntity {
  final String id;
  final String email;
  final Role role;

  UserEntity({required this.id, required this.email, required this.role});

  factory UserEntity.fromModel(AuthResponseModel model) {
    return UserEntity(
      id: model.user.id,
      email: model.user.email,
      role: Role.fromModel(model.user.role),
    );
  }
}

class Role {
  final int id;
  final String name;

  Role({required this.id, required this.name});

  factory Role.fromModel(RoleModel model) {
    return Role(id: model.id, name: model.name);
  }
}
