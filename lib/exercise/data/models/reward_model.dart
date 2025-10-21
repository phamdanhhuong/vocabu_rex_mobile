class RewardModel {
  final String type;
  final int amount;
  final String? title;

  RewardModel({required this.type, required this.amount, this.title});

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
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
