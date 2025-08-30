import 'package:vocabu_rex_mobile/home/data/datasources/home_datasource.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/user_profile_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeDatasource homeDatasource;
  HomeRepositoryImpl({required this.homeDatasource});

  @override
  Future<UserProfileEntity> getUserProfile() async {
    final model = await homeDatasource.getUserProfile();
    final result = UserProfileEntity.fromModel(model);
    return result;
  }
}
