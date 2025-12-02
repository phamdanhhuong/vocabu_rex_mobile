import 'package:get_it/get_it.dart';
import 'package:vocabu_rex_mobile/core/init_blocs/auth_injection.dart';
import 'package:vocabu_rex_mobile/core/init_blocs/home_injection.dart';
import 'package:vocabu_rex_mobile/core/init_blocs/exercise_injection.dart';
import 'package:vocabu_rex_mobile/core/init_blocs/profile_injection.dart';
import 'package:vocabu_rex_mobile/core/init_blocs/energy_injection.dart';
import 'package:vocabu_rex_mobile/core/init_blocs/streak_injection.dart';
import 'package:vocabu_rex_mobile/core/init_blocs/currency_injection.dart';
import 'package:vocabu_rex_mobile/core/init_blocs/chat_injection.dart';
import 'package:vocabu_rex_mobile/core/init_blocs/friend_injection.dart';
import 'package:vocabu_rex_mobile/core/init_blocs/pronunciation_injection.dart';
import 'package:vocabu_rex_mobile/core/init_blocs/feed_injection.dart';
import 'package:vocabu_rex_mobile/core/init_blocs/quest_injection.dart';
import 'package:vocabu_rex_mobile/core/init_blocs/leaderboard_injection.dart';
import 'package:vocabu_rex_mobile/core/init_blocs/achievement_injection.dart';

final sl = GetIt.instance;

void init() {
  // Initialize all feature modules
  initEnergy();
  initStreak();
  initAuth();
  initHome();
  initExercise();
  initProfile();
  initCurrency();
  initChat();
  initFriend();
  initPronunciationInjection();
  initFeed();
  initQuest();
  initLeaderboard();
  initAchievement();
}
