import 'package:vocabu_rex_mobile/currency/domain/usecases/get_currency_balance_usecase.dart';

import '../../domain/entities/currency_balance_entity.dart';
import '../../domain/entities/currency_transaction_entity.dart';
import '../datasources/currency_datasource.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final CurrencyDataSource remoteDataSource;

  CurrencyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<CurrencyBalanceEntity> getCurrencyBalance(String userId) async {
    final model = await remoteDataSource.getCurrencyBalance(userId);
    // Chuyển đổi từ model sang entity nếu cần
    return CurrencyBalanceEntity(
      userId: model.userId,
      gems: model.gems,
      coins: model.coins,
      lastUpdated: model.lastUpdated,
      totalEarned: model.totalEarned,
      totalSpent: model.totalSpent,
      recentTransactions: model.recentTransactions?.map((tx) => CurrencyTransactionEntity(
        id: tx.id,
        currencyType: tx.currencyType,
        amount: tx.amount,
        reason: tx.reason,
        description: tx.description,
        createdAt: tx.createdAt,
      )).toList(),
    );
  }
}
