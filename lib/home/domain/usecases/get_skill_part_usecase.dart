import 'package:vocabu_rex_mobile/home/domain/entities/skill_part_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/repositories/home_repository.dart';

class GetSkillPartUsecase {
  final HomeRepository homeRepository;
  GetSkillPartUsecase({required this.homeRepository});
  Future<List<SkillPartEntity>> call() async {
    return homeRepository.getSkillParts();
  }
}
