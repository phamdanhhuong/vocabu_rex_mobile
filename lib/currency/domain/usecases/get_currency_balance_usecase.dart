import 'package:vocabu_rex_mobile/currency/domain/entities/currency_balance_entity.dart';

abstract class CurrencyRepository {
  Future<CurrencyBalanceEntity> getCurrencyBalance(String userId);
}

class GetCurrencyBalanceUseCase {
  final CurrencyRepository repository;

  GetCurrencyBalanceUseCase({required this.repository});

  Future<CurrencyBalanceEntity> call(String userId) {
    return repository.getCurrencyBalance(userId);
  }
}
