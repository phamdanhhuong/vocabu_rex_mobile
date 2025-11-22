enum PostType {
  streakMilestone('STREAK_MILESTONE'),
  leaguePromotion('LEAGUE_PROMOTION'),
  leagueTop3('LEAGUE_TOP_3'),
  newFollower('NEW_FOLLOWER'),
  achievementUnlocked('ACHIEVEMENT_UNLOCKED'),
  levelUp('LEVEL_UP'),
  questCompleted('QUEST_COMPLETED'),
  perfectScore('PERFECT_SCORE'),
  xpMilestone('XP_MILESTONE');

  final String value;
  const PostType(this.value);

  static PostType? fromString(String value) {
    try {
      return PostType.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }
}

enum ReactionType {
  congrats('CONGRATS', '🎉', 'CHÚC MỪNG', 'ĐÃ CHÚC MỪNG'),
  fire('FIRE', '🔥', 'TUYỆT VỜI', 'ĐÃ TUYỆT VỜI'),
  clap('CLAP', '👏', 'ĐẬP TAY', 'ĐÃ ĐẬP TAY'),
  heart('HEART', '❤️', 'YÊU THÍCH', 'ĐÃ YÊU THÍCH'),
  strong('STRONG', '💪', 'MẠNH MẼ', 'ĐÃ MẠNH MẼ');

  final String value;
  final String emoji;
  final String actionText;
  final String reactedText;

  const ReactionType(this.value, this.emoji, this.actionText, this.reactedText);

  static ReactionType? fromString(String value) {
    try {
      return ReactionType.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }
}
