import 'package:vocabu_rex_mobile/currency/domain/entities/currency_balance_entity.dart';

abstract class CurrencyRepository {
  Future<CurrencyBalanceEntity> getCurrencyBalance(String userId);
}
