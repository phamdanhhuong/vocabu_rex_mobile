import 'package:vocabu_rex_mobile/leaderboard/domain/entities/leaderboard_standing_entity.dart';

class LeaderboardEntity {
  final String tier;
  final int groupNumber;
  final DateTime weekStartDate;
  final DateTime weekEndDate;
  final List<LeaderboardStandingEntity> standings;
  final int? userRank;
  final int totalParticipants;

  LeaderboardEntity({
    required this.tier,
    required this.groupNumber,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.standings,
    this.userRank,
    required this.totalParticipants,
  });

  factory LeaderboardEntity.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntity(
      tier: json['tier'] as String,
      groupNumber: json['groupNumber'] as int,
      weekStartDate: DateTime.parse(json['weekStartDate'] as String),
      weekEndDate: DateTime.parse(json['weekEndDate'] as String),
      standings: (json['standings'] as List<dynamic>)
          .map((e) => LeaderboardStandingEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      userRank: json['userRank'] as int?,
      totalParticipants: json['totalParticipants'] as int,
    );
  }

  String get tierDisplayName {
    switch (tier) {
      case 'BRONZE':
        return 'Đồng';
      case 'SILVER':
        return 'Bạc';
      case 'GOLD':
        return 'Vàng';
      case 'DIAMOND':
        return 'Kim cương';
      case 'OBSIDIAN':
        return 'Obsidian';
      default:
        return tier;
    }
  }
}
