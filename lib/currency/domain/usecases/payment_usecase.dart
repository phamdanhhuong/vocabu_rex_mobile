import 'package:vocabu_rex_mobile/currency/domain/entities/payment_entity.dart';
import 'package:vocabu_rex_mobile/currency/domain/repositories/payment_repository.dart';

class GetPaymentPackagesUseCase {
  final PaymentRepository repository;

  GetPaymentPackagesUseCase({required this.repository});

  Future<List<PaymentPackageEntity>> call() {
    return repository.getPackages();
  }
}

class CreatePaymentUseCase {
  final PaymentRepository repository;

  CreatePaymentUseCase({required this.repository});

  Future<CreatePaymentResultEntity> call(String packageId) {
    return repository.createPayment(packageId);
  }
}
