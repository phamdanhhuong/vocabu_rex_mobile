import 'package:vocabu_rex_mobile/home/domain/entities/skill_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/repositories/home_repository.dart';

class GetSkillByIdUsecase {
  final HomeRepository homeRepository;
  GetSkillByIdUsecase({required this.homeRepository});
  Future<SkillEntity> call(String id) async {
    return homeRepository.getSkillById(id);
  }
}
