import 'package:vocabu_rex_mobile/profile/domain/repositories/profile_repository.dart';

class ReportUserUsecase {
  final ProfileRepository repository;

  ReportUserUsecase(this.repository);

  Future<void> call({
    required String userId,
    required String reason,
    String? description,
  }) async {
    return await repository.reportUser(userId, reason, description);
  }
}
