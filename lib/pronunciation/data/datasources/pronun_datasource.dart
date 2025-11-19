import 'package:vocabu_rex_mobile/pronunciation/data/models/pronunciation_progress_model.dart';

abstract class PronunDatasource {
  Future<PronunciationProgressModel> getPronunProgress();
}
