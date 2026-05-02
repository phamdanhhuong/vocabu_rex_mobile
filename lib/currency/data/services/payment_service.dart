import 'package:dio/dio.dart';
import 'package:vocabu_rex_mobile/network/api_constants.dart';
import 'package:vocabu_rex_mobile/network/base_api_service.dart';


class PaymentService extends BaseApiService {
  // Singleton pattern
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  /// Lấy danh sách gói nạp
  Future<List<dynamic>> getPackages() async {
    try {
      final response = await client.get(ApiEndpoints.paymentPackages);
      final data = response.data;
      // Handle cả 2 trường hợp: response trực tiếp là List hoặc wrapped trong { data: [...] }
      if (data is List) return data;
      if (data is Map<String, dynamic>) return data['data'] ?? data.values.first;
      return [];
    } on DioException catch (error) {
      throw handleError(error);
    }
  }

  /// Tạo URL thanh toán VNPay
  Future<Map<String, dynamic>> createPayment(String packageId) async {
    try {
      final response = await client.post(
        ApiEndpoints.paymentCreate,
        data: {'packageId': packageId},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        // Nếu wrapped: { data: { paymentUrl, ... } }
        if (data.containsKey('paymentUrl')) return data;
        if (data.containsKey('data') && data['data'] is Map) return data['data'];
      }
      return data;
    } on DioException catch (error) {
      throw handleError(error);
    }
  }
}
