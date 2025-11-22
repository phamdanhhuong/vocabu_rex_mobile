enum QuestType {
  daily('DAILY'),
  friends('FRIENDS'),
  monthlyBadge('MONTHLY_BADGE');

  final String value;
  const QuestType(this.value);

  static QuestType fromString(String value) {
    switch (value) {
      case 'DAILY':
        return QuestType.daily;
      case 'FRIENDS':
        return QuestType.friends;
      case 'MONTHLY_BADGE':
        return QuestType.monthlyBadge;
      default:
        return QuestType.daily;
    }
  }
}

enum QuestCategory {
  lessons('LESSONS'),
  exercises('EXERCISES'),
  streak('STREAK'),
  xp('XP'),
  perfectScore('PERFECT_SCORE'),
  review('REVIEW'),
  social('SOCIAL'),
  studyTime('STUDY_TIME'),
  friendsChallenge('FRIENDS_CHALLENGE'),
  collection('COLLECTION');

  final String value;
  const QuestCategory(this.value);

  static QuestCategory fromString(String value) {
    switch (value) {
      case 'LESSONS':
        return QuestCategory.lessons;
      case 'EXERCISES':
        return QuestCategory.exercises;
      case 'STREAK':
        return QuestCategory.streak;
      case 'XP':
        return QuestCategory.xp;
      case 'PERFECT_SCORE':
        return QuestCategory.perfectScore;
      case 'REVIEW':
        return QuestCategory.review;
      case 'SOCIAL':
        return QuestCategory.social;
      case 'STUDY_TIME':
        return QuestCategory.studyTime;
      case 'FRIENDS_CHALLENGE':
        return QuestCategory.friendsChallenge;
      case 'COLLECTION':
        return QuestCategory.collection;
      default:
        return QuestCategory.lessons;
    }
  }
}

enum QuestStatus {
  active('ACTIVE'),
  completed('COMPLETED'),
  claimed('CLAIMED'),
  expired('EXPIRED');

  final String value;
  const QuestStatus(this.value);

  static QuestStatus fromString(String value) {
    switch (value) {
      case 'ACTIVE':
        return QuestStatus.active;
      case 'COMPLETED':
        return QuestStatus.completed;
      case 'CLAIMED':
        return QuestStatus.claimed;
      case 'EXPIRED':
        return QuestStatus.expired;
      default:
        return QuestStatus.active;
    }
  }
}

enum ChestType {
  bronze('BRONZE'),
  silver('SILVER'),
  gold('GOLD'),
  legendary('LEGENDARY');

  final String value;
  const ChestType(this.value);

  static ChestType fromString(String value) {
    switch (value) {
      case 'BRONZE':
        return ChestType.bronze;
      case 'SILVER':
        return ChestType.silver;
      case 'GOLD':
        return ChestType.gold;
      case 'LEGENDARY':
        return ChestType.legendary;
      default:
        return ChestType.bronze;
    }
  }
}

enum ChestStatus {
  locked('LOCKED'),
  unlocked('UNLOCKED'),
  opened('OPENED');

  final String value;
  const ChestStatus(this.value);

  static ChestStatus fromString(String value) {
    switch (value) {
      case 'LOCKED':
        return ChestStatus.locked;
      case 'UNLOCKED':
        return ChestStatus.unlocked;
      case 'OPENED':
        return ChestStatus.opened;
      default:
        return ChestStatus.locked;
    }
  }
}

enum DifficultyLevel {
  veryEasy('VERY_EASY'),
  easy('EASY'),
  normal('NORMAL'),
  hard('HARD'),
  veryHard('VERY_HARD');

  final String value;
  const DifficultyLevel(this.value);

  static DifficultyLevel fromString(String value) {
    switch (value) {
      case 'VERY_EASY':
        return DifficultyLevel.veryEasy;
      case 'EASY':
        return DifficultyLevel.easy;
      case 'NORMAL':
        return DifficultyLevel.normal;
      case 'HARD':
        return DifficultyLevel.hard;
      case 'VERY_HARD':
        return DifficultyLevel.veryHard;
      default:
        return DifficultyLevel.normal;
    }
  }
}
