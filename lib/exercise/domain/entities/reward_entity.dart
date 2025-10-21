class RewardEntity {
  final String type;
  final int amount;
  final String? title;

  RewardEntity({required this.type, required this.amount, this.title});

  factory RewardEntity.fromJson(Map<String, dynamic> json) {
    return RewardEntity(
      type: json['type'] as String,
      amount: json['amount'] is int ? json['amount'] as int : (json['amount'] as num).toInt(),
      title: json['title'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': amount,
      if (title != null) 'title': title,
    };
  }
}
