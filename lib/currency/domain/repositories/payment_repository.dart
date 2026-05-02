import 'package:vocabu_rex_mobile/currency/domain/entities/payment_entity.dart';

abstract class PaymentRepository {
  Future<List<PaymentPackageEntity>> getPackages();
  Future<CreatePaymentResultEntity> createPayment(String packageId);
}
