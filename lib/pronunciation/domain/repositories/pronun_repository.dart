import '../entities/entities.dart';

abstract class PronunRepository {
  /// Get pronunciation progress for the current user
  Future<PronunciationProgress?> getPronunciationProgress();
}
