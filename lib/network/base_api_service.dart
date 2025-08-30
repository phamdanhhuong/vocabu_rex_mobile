import 'package:dio/dio.dart';
import 'dio_client.dart';

abstract class BaseApiService {
  final DioClient _dioClient;

  BaseApiService() : _dioClient = DioClient.getInstance();

  // Getter để truy cập DioClient
  DioClient get client => _dioClient;

  // Phương thức xử lý lỗi chung
  String handleError(DioException error) {
    String errorMessage = '';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage = 'Kết nối timeout. Vui lòng thử lại.';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Gửi dữ liệu timeout. Vui lòng thử lại.';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Nhận dữ liệu timeout. Vui lòng thử lại.';
        break;
      case DioExceptionType.badResponse:
        switch (error.response?.statusCode) {
          case 400:
            errorMessage = 'Yêu cầu không hợp lệ.';
            break;
          case 401:
            errorMessage = 'Không có quyền truy cập. Vui lòng đăng nhập lại.';
            break;
          case 403:
            errorMessage = 'Bạn không có quyền thực hiện hành động này.';
            break;
          case 404:
            errorMessage = 'Không tìm thấy tài nguyên.';
            break;
          case 409:
            errorMessage = 'Dữ liệu đã tồn tại.';
            break;
          case 422:
            errorMessage = 'Dữ liệu không hợp lệ.';
            break;
          case 500:
            errorMessage = 'Lỗi server. Vui lòng thử lại sau.';
            break;
          default:
            errorMessage = 'Có lỗi xảy ra. Vui lòng thử lại.';
        }
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Yêu cầu đã bị hủy.';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'Không có kết nối internet. Vui lòng kiểm tra lại.';
        break;
      case DioExceptionType.unknown:
        errorMessage = 'Có lỗi không xác định. Vui lòng thử lại.';
        break;
      case DioExceptionType.badCertificate:
        errorMessage = 'Chứng chỉ không hợp lệ.';
        break;
    }

    return errorMessage;
  }

  // Phương thức xử lý response chung
  T handleResponse<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      return fromJson(response.data);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Request failed with status: ${response.statusCode}',
      );
    }
  }

  // Phương thức xử lý response list
  List<T> handleListResponse<T>(
    Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      List<dynamic> data = response.data;
      return data.map((item) => fromJson(item)).toList();
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Request failed with status: ${response.statusCode}',
      );
    }
  }
}
