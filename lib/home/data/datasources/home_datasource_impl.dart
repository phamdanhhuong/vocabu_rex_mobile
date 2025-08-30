import 'package:vocabu_rex_mobile/home/data/datasources/home_datasource.dart';
import 'package:vocabu_rex_mobile/home/data/models/user_profile_model.dart';
import 'package:vocabu_rex_mobile/home/data/service/home_service.dart';

class HomeDatasourceImpl implements HomeDatasource {
  final HomeService homeService;
  HomeDatasourceImpl(this.homeService);

  @override
  Future<UserProfileModel> getUserProfile() async {
    final res = await homeService.getUserProfile();
    final result = UserProfileModel.fromJson(res);
    return result;
  }
}
