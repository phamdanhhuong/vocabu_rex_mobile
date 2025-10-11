import 'package:vocabu_rex_mobile/currency/data/datasources/currency_datasource.dart';
import 'package:vocabu_rex_mobile/currency/data/models/currency_balance_model.dart';
import 'package:vocabu_rex_mobile/currency/data/services/currency_service.dart';


class CurrencyDataSourceImpl implements CurrencyDataSource {
  final CurrencyService currencyService;
  CurrencyDataSourceImpl(this.currencyService);

  @override
  Future<CurrencyBalanceModel> getCurrencyBalance(String userId) async {
    final res = await currencyService.getCurrencyBalance();
    final result = CurrencyBalanceModel.fromJson(res);
    return result;
  }
}
