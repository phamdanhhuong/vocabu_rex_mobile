import 'package:vocabu_rex_mobile/home/data/datasources/home_datasource.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/user_profile_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/user_progress_entity.dart';
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

  @override
  Future<UserProgressEntity> getUserProgress() async {
    final model = await homeDatasource.getUserProgress();
    final result = UserProgressEntity.fromModel(model);
    return result;
  }

  @override
  Future<SkillEntity> getSkillById(String id) async {
    final model = await homeDatasource.getSkillById(id);
    final result = SkillEntity.fromModel(model);
    return result;
  }
}
