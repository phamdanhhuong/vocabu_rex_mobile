import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/battle/ui/blocs/battle_bloc.dart';
import 'package:vocabu_rex_mobile/battle/ui/pages/battle_arena_page.dart';
import 'package:vocabu_rex_mobile/battle/ui/pages/vs_clash_screen.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/fab_cubit.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';

class BattlePage extends StatefulWidget {
  const BattlePage({super.key});
  @override
  State<BattlePage> createState() => _BattlePageState();
}

class _BattlePageState extends State<BattlePage> {
  @override
  void initState() {
    super.initState();
    context.read<BattleBloc>().add(BattleLoadStats());
    context.read<FabCubit>().hide();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppPreferences(),
      builder: (context, _) {
        final isDark = AppPreferences().isDarkMode;
        return BlocConsumer<BattleBloc, BattleState>(
          listenWhen: (p, c) => c is BattleMatchReady,
          listener: (ctx, st) {
            if (st is BattleMatchReady) {
              Navigator.of(
                ctx,
              ).push(MaterialPageRoute(builder: (_) => VsClashScreen(match: st.match)));
            }
          },
          builder: (ctx, st) {
            return Scaffold(
              body: Container(
                decoration: BoxDecoration(
                  color: isDark ? null : AppColors.snow,
                  gradient: isDark ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1E1E2C), Color(0xFF161622)],
                  ) : null,
                ),
                child: SafeArea(
                  child: st is BattleSearching ? _searching(ctx, isDark) : _landing(ctx, st, isDark),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _landing(BuildContext ctx, BattleState st, bool isDark) {
    final stats = st is BattleStatsLoaded ? st.stats : null;
    final history = st is BattleStatsLoaded ? st.history : [];
    final recentHistory = history.take(3).toList();
    
    return Stack(
      children: [
        // Subtle background grid or particles could go here
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              FadeInDown(
                child: _buildLeagueBadge(stats, isDark),
              ),
              const SizedBox(height: 32),

              if (stats != null)
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: _statsHologramRow(stats, isDark),
                ),
              const SizedBox(height: 32),

              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: _animatedLedButton(ctx, isDark),
              ),
              const SizedBox(height: 12),
              FadeIn(
                delay: const Duration(milliseconds: 600),
                child: Text(
                  'Miễn phí • 5 câu hỏi • 15 giây/câu',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : AppColors.hare,
                    fontFamily: 'DuolingoFeather',
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              FadeInUp(
                delay: const Duration(milliseconds: 700),
                child: _gladiatorQuestCard(isDark),
              ),

              const SizedBox(height: 32),
              
              if (recentHistory.isNotEmpty) ...[
                FadeInUp(
                  delay: const Duration(milliseconds: 700),
                  child: _sectionTitle('NHẬT KÝ GIAO TRANH', isDark),
                ),
                const SizedBox(height: 16),
                ...recentHistory.map((h) => FadeInUp(
                  delay: const Duration(milliseconds: 800),
                  child: _historyCard(h, isDark),
                )),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeagueBadge(dynamic stats, bool isDark) {
    String rankName = "Đồng";
    Color badgeColor = const Color(0xFFCD7F32);
    String badgeAsset = 'assets/achievements/highest_league_-_bronze_doing.png';
    
    if (stats != null) {
      if (stats.wins >= 50) {
        rankName = "Kim Cương";
        badgeColor = const Color(0xFF00E5FF);
        badgeAsset = 'assets/achievements/highest_league_-_diamond_doing.png';
      } else if (stats.wins >= 20) {
        rankName = "Vàng";
        badgeColor = const Color(0xFFFFD700);
        badgeAsset = 'assets/achievements/highest_league_-_gold_doing.png';
      } else if (stats.wins >= 5) {
        rankName = "Bạc";
        badgeColor = const Color(0xFFC0C0C0);
        badgeAsset = 'assets/achievements/highest_league_-_silver_doing.png';
      }
    }

    return Column(
      children: [
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: badgeColor.withValues(alpha: 0.6),
                blurRadius: 60,
                spreadRadius: 10,
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              badgeAsset,
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              rankName.toUpperCase(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppColors.bodyText,
                fontFamily: 'DuolingoFeather',
                letterSpacing: 1.5,
                shadows: [
                  Shadow(
                    color: badgeColor.withValues(alpha: 0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.info_outline,
              color: isDark ? Colors.white.withValues(alpha: 0.2) : AppColors.swan,
              size: 20,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'ĐẤU TRƯỜNG TRANH HẠNG',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white54 : AppColors.wolf,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _animatedLedButton(BuildContext ctx, bool isDark) {
    return Container(
      width: double.infinity,
      height: 68,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.macaw.withValues(alpha: 0.4),
            blurRadius: 25,
            spreadRadius: 2,
          ),
        ],
      ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: OverflowBox(
                  maxWidth: 600,
                  maxHeight: 600,
                  child: Spin(
                    infinite: true,
                    duration: const Duration(seconds: 3),
                    child: Container(
                      width: 500,
                      height: 500,
                      decoration: BoxDecoration(
                        gradient: SweepGradient(
                          colors: [
                            AppColors.macaw.withValues(alpha: 0.0),
                            isDark ? Colors.white : AppColors.macaw,
                            AppColors.macaw.withValues(alpha: 0.0),
                          ],
                          stops: const [0.0, 0.2, 0.4],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161622) : AppColors.snow,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: AppButton(
                    label: '⚔️ TÌM TRẬN ĐẤU',
                    onPressed: () => ctx.read<BattleBloc>().add(BattleFindMatch()),
                    backgroundColor: AppColors.macaw,
                    shadowColor: const Color(0xFF0D8A4E),
                    width: double.infinity,
                    size: ButtonSize.large,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
  }

  Widget _gladiatorQuestCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A3C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.bee.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.bee.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.military_tech, color: AppColors.bee, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NHIỆM VỤ ĐẤU SĨ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.bee,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Thắng 3 trận xếp hạng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.bodyText,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.33,
                          backgroundColor: Colors.white12,
                          color: AppColors.bee,
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '1/3',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : AppColors.wolf,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              const Icon(Icons.diamond, color: AppColors.macaw, size: 24),
              const SizedBox(height: 4),
              Text(
                '100',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.macaw,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statsHologramRow(dynamic s, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _hologramCard('THẮNG', '${s.wins}', AppColors.featherGreen, isDark: isDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _hologramCard('TỈ LỆ', '${s.winRate.toStringAsFixed(1)}%', const Color(0xFF00E5FF), isDark: isDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: s.winStreak >= 3 
              ? Pulse(
                  infinite: true,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: isDark ? AppColors.bee.withValues(alpha: 0.5) : AppColors.bee.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 2)
                      ],
                    ),
                    child: _hologramCard('STREAK', '${s.winStreak}🔥', AppColors.bee, isFire: true, isDark: isDark),
                  ),
                )
              : _hologramCard('STREAK', '${s.winStreak}🔥', AppColors.bee, isDark: isDark),
        ),
      ],
    );
  }

  Widget _hologramCard(String label, String value, Color color, {bool isFire = false, required bool isDark}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: isDark ? color.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isFire ? AppColors.bee : (isDark ? color.withValues(alpha: 0.3) : AppColors.swan),
              width: isFire ? 2 : 1,
            ),
            gradient: isFire ? LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                isDark ? AppColors.cardinal.withValues(alpha: 0.3) : AppColors.cardinal.withValues(alpha: 0.1),
                isDark ? AppColors.bee.withValues(alpha: 0.1) : AppColors.bee.withValues(alpha: 0.05),
              ]
            ) : null,
          ),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: isFire ? AppColors.bee : (isDark ? Colors.white : AppColors.bodyText),
                  fontFamily: 'DuolingoFeather',
                  shadows: isDark ? [
                    Shadow(color: color.withValues(alpha: 0.5), blurRadius: 10),
                  ] : null,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : AppColors.wolf,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String t, bool isDark) {
    return Row(
      children: [
        Expanded(child: Divider(color: isDark ? Colors.white24 : AppColors.swan)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            t,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white54 : AppColors.bodyText,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Expanded(child: Divider(color: isDark ? Colors.white24 : AppColors.swan)),
      ],
    );
  }

  Widget _historyCard(dynamic h, bool isDark) {
    final bool isWin = h.result == 'WIN';
    final Color cardColor = isWin ? AppColors.featherGreen : AppColors.cardinal;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A3C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? cardColor.withValues(alpha: 0.3) : AppColors.swan),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.3) : AppColors.swan.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (!isWin)
            Positioned(
              right: -20,
              top: -10,
              child: Opacity(
                opacity: 0.1,
                child: Transform.rotate(
                  angle: -math.pi / 4,
                  child: Container(
                    width: 100,
                    height: 10,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [cardColor, cardColor.withValues(alpha: 0.5)],
                    ),
                    boxShadow: [
                      if (isWin)
                        BoxShadow(color: cardColor.withValues(alpha: 0.4), blurRadius: 12)
                    ],
                  ),
                  child: Icon(
                    isWin ? Icons.emoji_events : Icons.close,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        h.opponent?.displayName ?? (h.isBot ? 'Hệ thống (Bot)' : 'Ẩn danh'),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: isDark ? Colors.white : AppColors.bodyText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tỉ số: ${h.myScore} - ${h.opponentScore}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : AppColors.wolf,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isWin ? '+${h.xpEarned}' : '${h.xpEarned}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isWin ? AppColors.bee : (isDark ? Colors.white60 : AppColors.bodyText),
                        fontFamily: 'DuolingoFeather',
                      ),
                    ),
                    Text(
                      'XP',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : AppColors.hare,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searching(BuildContext ctx, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Pulse(
                infinite: true,
                duration: const Duration(seconds: 2),
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.1), width: 2),
                  ),
                ),
              ),
              Pulse(
                infinite: true,
                duration: const Duration(milliseconds: 1500),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3), width: 2),
                  ),
                ),
              ),
              Spin(
                infinite: true,
                duration: const Duration(seconds: 2),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        Colors.transparent,
                        const Color(0xFF00E5FF).withValues(alpha: 0.1),
                        const Color(0xFF00E5FF).withValues(alpha: 0.6),
                      ],
                      stops: const [0.0, 0.8, 1.0],
                    ),
                  ),
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.radar, color: Colors.white, size: 40),
              ),
            ],
          ),
          const SizedBox(height: 60),
          Text(
            'ĐANG QUÉT ĐỐI THỦ...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isDark ? const Color(0xFF00E5FF) : AppColors.macaw,
              letterSpacing: 2,
              fontFamily: 'DuolingoFeather',
              shadows: isDark ? [
                Shadow(color: const Color(0xFF00E5FF).withValues(alpha: 0.5), blurRadius: 10),
              ] : [],
            ),
          ),
          const SizedBox(height: 40),
          TextButton(
            onPressed: () => ctx.read<BattleBloc>().add(BattleCancelSearch()),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              backgroundColor: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.swan,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(
              'HỦY TÌM KIẾM',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : AppColors.bodyText,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
