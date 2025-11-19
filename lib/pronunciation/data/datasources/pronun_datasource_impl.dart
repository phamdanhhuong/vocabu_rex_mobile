import 'package:vocabu_rex_mobile/pronunciation/data/datasources/pronun_datasource.dart';
import 'package:vocabu_rex_mobile/pronunciation/data/models/pronunciation_progress_model.dart';
import 'package:vocabu_rex_mobile/pronunciation/data/services/pronunciation_service.dart';

class ProfileDataSourceImpl implements PronunDatasource {
  final PronunciationServive pronunciationServive;
  ProfileDataSourceImpl(this.pronunciationServive);

  @override
  Future<PronunciationProgressModel> getPronunProgress() async {
    final res = await pronunciationServive.getProgress();
    return PronunciationProgressModel.fromJson(res);
  }
}
