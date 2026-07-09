import 'package:get_it/get_it.dart';
import '../../network/dio_client.dart';
import '../../shop/data/datasources/shop_datasource.dart';
import '../../shop/ui/blocs/shop_bloc.dart';

final sl = GetIt.instance;

void initShop() {
  sl.registerLazySingleton<ShopDatasource>(
    () => ShopDatasource(DioClient.getInstance().dio),
  );

  sl.registerLazySingleton(
    () => ShopBloc(sl<ShopDatasource>()),
  );
}
