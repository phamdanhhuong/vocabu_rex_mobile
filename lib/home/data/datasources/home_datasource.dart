import 'package:vocabu_rex_mobile/home/data/models/user_profile_model.dart';

abstract class HomeDatasource {
  Future<UserProfileModel> getUserProfile();
}
