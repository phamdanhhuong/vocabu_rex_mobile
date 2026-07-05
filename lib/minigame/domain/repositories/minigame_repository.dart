import 'package:vocabu_rex_mobile/minigame/domain/entities/minigame_session_entity.dart';
import 'package:vocabu_rex_mobile/minigame/domain/entities/minigame_result_entity.dart';
import 'package:vocabu_rex_mobile/minigame/domain/entities/minigame_status_entity.dart';

abstract class MiniGameRepository {
  /// Lấy session chơi game (danh sách exercises + kỷ lục cũ)
  Future<MiniGameSessionEntity> getSession({
    required String partId,
    required String gameType,
  });

  /// Submit kết quả và nhận về sao + xu thưởng
  Future<MiniGameResultEntity> submit({
    required String partId,
    required String gameType,
    required int score,
    required int timeSpentMs,
    required int mistakesCount,
  });

  /// Lấy trạng thái kỷ lục của cả 2 game type cho 1 part
  Future<List<MiniGameStatusEntity>> getStatus(String partId);
}
