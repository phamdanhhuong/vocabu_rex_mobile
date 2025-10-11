
import 'package:vocabu_rex_mobile/currency/domain/entities/currency_transaction_entity.dart';

class CurrencyBalanceEntity {
  final String userId;
  final int gems;
  final int coins;
  final DateTime lastUpdated;
  final Map<String, int>? totalEarned;
  final Map<String, int>? totalSpent;
  final List<CurrencyTransactionEntity>? recentTransactions;

  CurrencyBalanceEntity({
    required this.userId,
    required this.gems,
    required this.coins,
    required this.lastUpdated,
    this.totalEarned,
    this.totalSpent,
    this.recentTransactions,
  });
}