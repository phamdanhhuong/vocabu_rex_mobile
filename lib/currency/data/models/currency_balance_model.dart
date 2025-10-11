class CurrencyTransactionModel {
	final String id;
	final String currencyType;
	final int amount;
	final String reason;
	final String? description;
	final DateTime createdAt;

	CurrencyTransactionModel({
		required this.id,
		required this.currencyType,
		required this.amount,
		required this.reason,
		this.description,
		required this.createdAt,
	});

	factory CurrencyTransactionModel.fromJson(Map<String, dynamic> json) {
		return CurrencyTransactionModel(
			id: json['id'] as String,
			currencyType: json['currencyType'] as String,
			amount: json['amount'] as int,
			reason: json['reason'] as String,
			description: json['description'] as String?,
			createdAt: DateTime.parse(json['createdAt'] as String),
		);
	}
}

class CurrencyBalanceModel {
	final String userId;
	final int gems;
	final int coins;
	final DateTime lastUpdated;
	final Map<String, int>? totalEarned;
	final Map<String, int>? totalSpent;
	final List<CurrencyTransactionModel>? recentTransactions;

	CurrencyBalanceModel({
		required this.userId,
		required this.gems,
		required this.coins,
		required this.lastUpdated,
		this.totalEarned,
		this.totalSpent,
		this.recentTransactions,
	});

	factory CurrencyBalanceModel.fromJson(Map<String, dynamic> json) {
		return CurrencyBalanceModel(
			userId: json['userId'] as String,
			gems: json['gems'] as int,
			coins: json['coins'] as int,
			lastUpdated: DateTime.parse(json['lastUpdated'] as String),
			totalEarned: json['totalEarned'] != null
					? {
							'gems': json['totalEarned']['gems'] as int,
							'coins': json['totalEarned']['coins'] as int,
						}
					: null,
			totalSpent: json['totalSpent'] != null
					? {
							'gems': json['totalSpent']['gems'] as int,
							'coins': json['totalSpent']['coins'] as int,
						}
					: null,
			recentTransactions: json['recentTransactions'] != null
					? (json['recentTransactions'] as List)
							.map((e) => CurrencyTransactionModel.fromJson(e))
							.toList()
					: null,
		);
	}
}
