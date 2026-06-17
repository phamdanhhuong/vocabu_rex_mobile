import 'package:dio/dio.dart';
import '../models/shop_model.dart';

class ShopDatasource {
  final Dio _dio;

  ShopDatasource(this._dio);

  Future<List<ShopItemModel>> getShopItems() async {
    final response = await _dio.get('/shop/items');
    return (response.data as List).map((e) => ShopItemModel.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> buyItem(String itemId) async {
    final response = await _dio.post('/shop/buy/$itemId');
    return response.data;
  }

  Future<Map<String, dynamic>> openChest() async {
    final response = await _dio.post('/shop/open-chest');
    return response.data;
  }

  Future<List<UserInventoryModel>> getInventory() async {
    final response = await _dio.get('/inventory');
    return (response.data as List).map((e) => UserInventoryModel.fromJson(e)).toList();
  }

  Future<UserEquippedItemModel> getEquippedItem() async {
    final response = await _dio.get('/inventory/equipped');
    return UserEquippedItemModel.fromJson(response.data);
  }

  Future<Map<String, dynamic>> equipItem(String itemId) async {
    final response = await _dio.put('/inventory/equip/$itemId');
    return response.data;
  }

  Future<Map<String, dynamic>> useItem(String itemId) async {
    final response = await _dio.post('/inventory/use/$itemId');
    return response.data;
  }
}
