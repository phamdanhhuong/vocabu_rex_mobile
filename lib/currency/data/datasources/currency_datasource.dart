import '../models/currency_balance_model.dart';

abstract class CurrencyDataSource {
  Future<CurrencyBalanceModel> getCurrencyBalance(String userId);
}