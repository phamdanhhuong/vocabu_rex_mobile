import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/submit_response_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/pages/streak_update_page.dart';
import 'package:vocabu_rex_mobile/exercise/ui/pages/lesson_overview_page.dart';
import 'package:vocabu_rex_mobile/exercise/ui/pages/reward_collect_page.dart';

/// Coordinator để điều phối việc hiển thị các trang phần thưởng sau khi hoàn thành bài học
/// Thứ tự: Streak Update -> Overview -> Rewards (Gems/Coins)
class RewardFlowCoordinator {
  /// Hiển thị toàn bộ flow phần thưởng theo thứ tự
  ///
  /// Parameters:
  /// - [context]: BuildContext để navigation
  /// - [response]: Kết quả submit bài học (contains streakData and completedQuests from backend)
  /// - [completionTime]: Thời gian hoàn thành bài học (optional)
  ///
  /// Returns: Future<bool> - true nếu user đã xem hết các trang
  static Future<bool> showRewardFlow({
    required BuildContext context,
    required SubmitResponseEntity response,
    Duration? completionTime,
  }) async {
    // 1. Trang cập nhật streak (nếu có từ backend)
    final streakData = response.streakData;
    if (streakData != null &&
        streakData['hasStreakIncreased'] == true &&
        streakData['previousStreak'] != null &&
        streakData['currentStreak'] != null) {
      final streakShown = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => StreakUpdatePage(
            previousStreak: streakData['previousStreak'] as int,
            newStreak: streakData['currentStreak'] as int,
            isPerfect: response.isPerfect,
          ),
          fullscreenDialog: true,
        ),
      );

      if (streakShown != true) return false;
    }

    // 2. Trang Overview (XP, accuracy, time)
    final overviewShown = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => LessonOverviewPage(
          response: response,
          completionTime: completionTime,
        ),
        fullscreenDialog: true,
      ),
    );

    if (overviewShown != true) return false;

    // 3. Trang nhận thưởng (Gems và Coins)
    int totalGems = 0;
    int totalCoins = 0;

    // Debug: Print rewards to see what we received
    print('🎁 Rewards received: ${response.rewards.length} items');
    for (final reward in response.rewards) {
      print('  - Type: ${reward.type}, Amount: ${reward.amount}');
    }

    // Extract gems and coins from rewards
    for (final reward in response.rewards) {
      final type = reward.type.toLowerCase();
      if (type == 'gems' || type == 'gem') {
        totalGems += reward.amount;
      } else if (type == 'coins' || type == 'coin') {
        totalCoins += reward.amount;
      }
    }

    print('💎 Total gems: $totalGems, 🪙 Total coins: $totalCoins');

    // Show rewards page if there are any gems or coins
    if (totalGems > 0 || totalCoins > 0) {
      final rewardsShown = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) =>
              RewardCollectPage(gems: totalGems, coins: totalCoins),
          fullscreenDialog: true,
        ),
      );

      if (rewardsShown != true) return false;
    }

    return true;
  }
}
