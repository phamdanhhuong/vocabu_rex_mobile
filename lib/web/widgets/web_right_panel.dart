import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/streak/ui/blocs/streak_bloc.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/quest_bloc.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/quest_state.dart';
import 'package:vocabu_rex_mobile/leaderboard/ui/blocs/leaderboard_bloc.dart';
import 'package:vocabu_rex_mobile/leaderboard/ui/blocs/leaderboard_state.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';

/// Right panel for web layout showing stats, quests, and leaderboard snippets.
class WebRightPanel extends StatelessWidget {
  const WebRightPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppPreferences(),
      builder: (context, _) {
        return Container(
          width: 300,
          decoration: BoxDecoration(
            color: AppColors.snow,
            border: Border(left: BorderSide(color: AppColors.swan, width: 2)),
          ),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _StreakWidget(),
              const SizedBox(height: 16),
              _DailyQuestWidget(),
              const SizedBox(height: 16),
              _LeaderboardSnippet(),
            ],
          ),
        );
      },
    );
  }
}

// ── Streak Card ──────────────────────────────────────────
class _StreakWidget extends StatelessWidget {
  const _StreakWidget();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StreakBloc, StreakState>(
      builder: (context, state) {
        int streakCount = 0;
        if (state is StreakLoaded) {
          streakCount = state.response.currentStreak.length;
        }

        return _PanelCard(
          child: Column(
            children: [
              Icon(
                Icons.local_fire_department,
                color: Colors.orange,
                size: 40,
              ),
              SizedBox(height: 8),
              Text(
                '$streakCount',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 4),
              Text(
                streakCount == 1 ? 'ngày streak' : 'ngày streak',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.wolf,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Daily Quest Snippet ──────────────────────────────────
class _DailyQuestWidget extends StatelessWidget {
  const _DailyQuestWidget();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuestBloc, QuestState>(
      builder: (context, state) {
        if (state is QuestLoaded) {
          final completedCount = state.completedToday;
          final totalCount = state.totalDaily;

          return _PanelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: AppColors.bee,
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Nhiệm vụ hàng ngày',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.eel,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: totalCount > 0 ? completedCount / totalCount : 0,
                    minHeight: 10,
                    backgroundColor: AppColors.swan,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.featherGreen,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '$completedCount / $totalCount hoàn thành',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.wolf,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return _PanelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: AppColors.bee,
                    size: 22,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Nhiệm vụ hàng ngày',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.eel,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                'Đang tải...',
                style: TextStyle(color: AppColors.wolf, fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Leaderboard Snippet ──────────────────────────────────
class _LeaderboardSnippet extends StatelessWidget {
  const _LeaderboardSnippet();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        if (state is LeaderboardLoaded) {
          final topUsers = state.leaderboard.standings.take(5).toList();

          return _PanelCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.leaderboard,
                      color: AppColors.macaw,
                      size: 22,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Bảng xếp hạng',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.eel,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ...topUsers.map((user) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          child: Text(
                            '${user.rank}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: user.rank <= 3
                                  ? AppColors.macaw
                                  : AppColors.wolf,
                            ),
                          ),
                        ),
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.swan,
                          child: Text(
                            (user.fullName ?? 'U')[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.eel,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            user.fullName ?? 'Người dùng',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.eel,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${user.weeklyXp} XP',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.wolf,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        }

        return _PanelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.leaderboard,
                    color: AppColors.macaw,
                    size: 22,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Bảng xếp hạng',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.eel,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                'Đang tải...',
                style: TextStyle(color: AppColors.wolf, fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Reusable Panel Card ──────────────────────────────────
class _PanelCard extends StatelessWidget {
  final Widget child;
  const _PanelCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.swan, width: 2),
      ),
      child: child,
    );
  }
}
