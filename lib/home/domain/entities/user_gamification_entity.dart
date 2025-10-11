class UserGamificationEntity {
  final int gem;
  final int coin;
  final int energy;
  final int streak;

  UserGamificationEntity({
    required this.gem,
    required this.coin,
    required this.energy,
    required this.streak,
  });

  factory UserGamificationEntity.fromJson(Map<String, dynamic> json) {
    return UserGamificationEntity(
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

  UserGamificationEntity copyWith({
    int? gem,
    int? coin,
    int? energy,
    int? streak,
  }) {
    return UserGamificationEntity(
      gem: gem ?? this.gem,
      coin: coin ?? this.coin,
      energy: energy ?? this.energy,
      streak: streak ?? this.streak,
    );
  }
}
