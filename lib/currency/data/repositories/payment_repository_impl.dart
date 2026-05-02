import 'package:vocabu_rex_mobile/currency/data/datasources/payment_datasource.dart';
import 'package:vocabu_rex_mobile/currency/domain/entities/payment_entity.dart';
import 'package:vocabu_rex_mobile/currency/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentDataSource remoteDataSource;

  PaymentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PaymentPackageEntity>> getPackages() async {
    final models = await remoteDataSource.getPackages();
    return models
        .map((m) => PaymentPackageEntity(
              id: m.id,
              name: m.name,
              price: m.price,
              gems: m.gems,
              coins: m.coins,
            ))
        .toList();
  }

  @override
  Future<CreatePaymentResultEntity> createPayment(String packageId) async {
    final model = await remoteDataSource.createPayment(packageId);
    return CreatePaymentResultEntity(
      paymentUrl: model.paymentUrl,
      orderId: model.orderId,
      orderCode: model.orderCode,
      amount: model.amount,
      packageName: model.packageName,
    );
  }
}
