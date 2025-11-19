import '../../domain/entities/entities.dart';
import '../../domain/repositories/pronun_repository.dart';
import '../datasources/pronun_datasource.dart';

class PronunRepositoryImpl implements PronunRepository {
  final PronunDatasource dataSource;

  PronunRepositoryImpl({required this.dataSource});

  @override
  Future<PronunciationProgress?> getPronunciationProgress() async {
    try {
      final model = await dataSource.getPronunProgress();
      return PronunciationProgress.fromModel(model);
    } catch (e) {
      throw Exception('Failed to get pronunciation progress: $e');
    }
  }
}
