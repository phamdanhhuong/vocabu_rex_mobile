import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/battle/ui/blocs/battle_bloc.dart';
import 'package:vocabu_rex_mobile/battle/ui/pages/battle_arena_page.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/fab_cubit.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:math' as math;
import 'dart:ui';

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
    return BlocConsumer<BattleBloc, BattleState>(
      listenWhen: (p, c) => c is BattleMatchReady,
      listener: (ctx, st) {
        if (st is BattleMatchReady) {
          Navigator.of(
            ctx,
          ).push(MaterialPageRoute(builder: (_) => const BattleArenaPage()));
        }
      },
      builder: (ctx, st) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1E1E2C), Color(0xFF161622)], // Dark sci-fi arena gradient
              ),
            ),
            child: SafeArea(
              child: st is BattleSearching ? _searching(ctx) : _landing(ctx, st),
            ),
          ),
        );
      },
    );
  }

  Widget _landing(BuildContext ctx, BattleState st) {
    final stats = st is BattleStatsLoaded ? st.stats : null;
    final history = st is BattleStatsLoaded ? st.history : [];
    
    return Stack(
      children: [
        // Subtle background grid or particles could go here
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // 1. Header - League Badge
              FadeInDown(
                child: _buildLeagueBadge(stats),
              ),
              const SizedBox(height: 32),

              // 2. Khu Vực Lửa Chiến (Hologram Stats)
              if (stats != null)
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: _statsHologramRow(stats),
                ),
              const SizedBox(height: 32),

              // 3. Colossal Match Button
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: _animatedLedButton(ctx),
              ),
              const SizedBox(height: 12),
              FadeIn(
                delay: const Duration(milliseconds: 600),
                child: Text(
                  'Miễn phí • 5 câu hỏi • 15 giây/câu',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white60,
                    fontFamily: 'DuolingoFeather',
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 4. Gladiator Quests (Nhiệm Vụ Đấu Sĩ)
              FadeInUp(
                delay: const Duration(milliseconds: 700),
                child: _gladiatorQuestCard(),
              ),

              const SizedBox(height: 32),
              
              // 5. Lịch sử giao tranh
              if (history.isNotEmpty) ...[
                FadeInUp(
                  delay: const Duration(milliseconds: 800),
                  child: _sectionTitle('NHẬT KÝ GIAO TRANH'),
                ),
                const SizedBox(height: 16),
                ...history.map((h) => FadeInUp(
                  delay: const Duration(milliseconds: 900),
                  child: _historyCard(h),
                )),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeagueBadge(dynamic stats) {
    // Mock rank based on wins
    String rankName = "Đồng";
    Color badgeColor = const Color(0xFFCD7F32); // Bronze
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
        // Aura Badge
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
        Text(
          rankName.toUpperCase(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 2,
            fontFamily: 'DuolingoFeather',
            shadows: [
              Shadow(color: badgeColor, blurRadius: 10),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'ĐẤU TRƯỜNG TRANH HẠNG',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white54,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _animatedLedButton(BuildContext ctx) {
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
            // Rotating LED Gradient
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
                      width: 500, // Large square to rotate smoothly without jumping
                      height: 500,
                      decoration: BoxDecoration(
                        gradient: SweepGradient(
                          colors: [
                            AppColors.macaw.withValues(alpha: 0.0),
                            Colors.white,
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
            // Inner AppButton
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF161622),
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

  Widget _gladiatorQuestCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.bee.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
                        color: Colors.white70,
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

  Widget _statsHologramRow(dynamic s) {
    return Row(
      children: [
        Expanded(
          child: _hologramCard('THẮNG', '${s.wins}', AppColors.featherGreen),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _hologramCard('TỈ LỆ', '${s.winRate.toStringAsFixed(1)}%', const Color(0xFF00E5FF)),
        ),
        const SizedBox(width: 12),
        // Streak Card (On Fire if streak >= 3)
        Expanded(
          child: s.winStreak >= 3 
              ? Pulse(
                  infinite: true,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: AppColors.bee.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 2)
                      ],
                    ),
                    child: _hologramCard('STREAK', '${s.winStreak}🔥', AppColors.bee, isFire: true),
                  ),
                )
              : _hologramCard('STREAK', '${s.winStreak}🔥', AppColors.bee),
        ),
      ],
    );
  }

  Widget _hologramCard(String label, String value, Color color, {bool isFire = false}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isFire ? AppColors.bee : color.withValues(alpha: 0.3),
              width: isFire ? 2 : 1,
            ),
            gradient: isFire ? LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                AppColors.cardinal.withValues(alpha: 0.3),
                AppColors.bee.withValues(alpha: 0.1),
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
                  color: isFire ? AppColors.bee : Colors.white,
                  fontFamily: 'DuolingoFeather',
                  shadows: [
                    Shadow(color: color.withValues(alpha: 0.5), blurRadius: 10),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
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

  Widget _sectionTitle(String t) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white24)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            t,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white54,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.white24)),
      ],
    );
  }

  Widget _historyCard(dynamic h) {
    final bool isWin = h.result == 'WIN';
    final Color cardColor = isWin ? AppColors.featherGreen : AppColors.cardinal;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // If Lose, show a subtle slash mark in background
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
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar/Icon
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
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tỉ số: ${h.myScore} - ${h.opponentScore}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white60,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // XP Earned
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isWin ? '+${h.xpEarned}' : '${h.xpEarned}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isWin ? AppColors.bee : Colors.white60,
                        fontFamily: 'DuolingoFeather',
                      ),
                    ),
                    Text(
                      'XP',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
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

  Widget _searching(BuildContext ctx) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Radar Sweep Animation
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse rings
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
              // Radar Spinner
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
              // Center Core
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
              color: const Color(0xFF00E5FF),
              letterSpacing: 2,
              fontFamily: 'DuolingoFeather',
              shadows: [
                Shadow(color: const Color(0xFF00E5FF).withValues(alpha: 0.5), blurRadius: 10),
              ],
            ),
          ),
          const SizedBox(height: 40),
          TextButton(
            onPressed: () => ctx.read<BattleBloc>().add(BattleCancelSearch()),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text(
              'HỦY TÌM KIẾM',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
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
