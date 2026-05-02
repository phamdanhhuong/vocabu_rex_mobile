import 'package:vocabu_rex_mobile/currency/data/datasources/payment_datasource.dart';
import 'package:vocabu_rex_mobile/currency/data/models/payment_model.dart';
import 'package:vocabu_rex_mobile/currency/data/services/payment_service.dart';

class PaymentDataSourceImpl implements PaymentDataSource {
  final PaymentService paymentService;
  PaymentDataSourceImpl(this.paymentService);

  @override
  Future<List<PaymentPackageModel>> getPackages() async {
    final res = await paymentService.getPackages();
    return res
        .map((e) => PaymentPackageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CreatePaymentResultModel> createPayment(String packageId) async {
    final res = await paymentService.createPayment(packageId);
    return CreatePaymentResultModel.fromJson(res);
  }
}
