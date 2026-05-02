import '../models/payment_model.dart';

abstract class PaymentDataSource {
  Future<List<PaymentPackageModel>> getPackages();
  Future<CreatePaymentResultModel> createPayment(String packageId);
}
