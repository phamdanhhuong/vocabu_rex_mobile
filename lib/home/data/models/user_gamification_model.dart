class UserGamificationModel {
  final int gem;
  final int coin;
  final int energy;
  final int streak;

  UserGamificationModel({
    required this.gem,
    required this.coin,
    required this.energy,
    required this.streak,
  });

  factory UserGamificationModel.fromJson(Map<String, dynamic> json) {
    return UserGamificationModel(
      gem: json['gem'] as int? ?? 0,
      coin: json['coin'] as int? ?? 0,
      energy: json['energy'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gem': gem,
      'coin': coin,
      'energy': energy,
      'streak': streak,
    };
  }

  UserGamificationModel copyWith({
    int? gem,
    int? coin,
    int? energy,
    int? streak,
  }) {
    return UserGamificationModel(
      gem: gem ?? this.gem,
      coin: coin ?? this.coin,
      energy: energy ?? this.energy,
      streak: streak ?? this.streak,
    );
  }
}
