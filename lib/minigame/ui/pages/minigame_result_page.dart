import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vocabu_rex_mobile/currency/ui/blocs/currency_bloc.dart';
import 'package:vocabu_rex_mobile/minigame/domain/entities/minigame_result_entity.dart';
import 'package:vocabu_rex_mobile/minigame/ui/blocs/minigame_bloc.dart';
import 'package:vocabu_rex_mobile/minigame/ui/pages/minigame_play_page.dart';
import 'package:vocabu_rex_mobile/minigame/ui/widgets/star_display_widget.dart';
import 'package:vocabu_rex_mobile/core/interaction_service.dart';
import 'package:vocabu_rex_mobile/core/injection.dart';

class MiniGameResultPage extends StatefulWidget {
  final MiniGameResultEntity result;
  final String gameType;
  final String partId;
  final String milestoneName;

  const MiniGameResultPage({
    super.key,
    required this.result,
    required this.gameType,
    required this.partId,
    required this.milestoneName,
  });

  @override
  State<MiniGameResultPage> createState() => _MiniGameResultPageState();
}

class _MiniGameResultPageState extends State<MiniGameResultPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgCtrl;

  bool get isArcade => widget.gameType == 'ARCADE';

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    // Play reward sound
    Future.delayed(const Duration(milliseconds: 300), () {
      InteractionService.playReward();
    });

    // Refresh currency balance
    Future.microtask(() {
      if (mounted) {
        context.read<CurrencyBloc>().add(GetCurrencyBalanceEvent(''));
      }
    });
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    super.dispose();
  }

  String _formatTime(int ms) {
    final secs = ms ~/ 1000;
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final isNewRecord = result.isNewHighScore || result.rewardedCoins > 0;

    // Màu theme theo mode
    final List<Color> themeColors = isArcade
        ? [const Color(0xFFFF6B35), const Color(0xFFE91E8C)]
        : [const Color(0xFF7C4DFF), const Color(0xFF00BCD4)];
    final Color glowColor = themeColors[0];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (ctx, _) => Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(
                    -0.2 + _bgCtrl.value * 0.4,
                    -0.3 + _bgCtrl.value * 0.3,
                  ),
                  radius: 1.2,
                  colors: [
                    themeColors[0].withOpacity(0.15),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // ── Title ───────────────────────────────────────
                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      child: Column(
                        children: [
                          Text(
                            result.newStars >= 3
                                ? '🎉 Hoàn Hảo!'
                                : result.newStars >= 2
                                    ? '✨ Xuất Sắc!'
                                    : result.newStars >= 1
                                        ? '👍 Tốt Lắm!'
                                        : '💪 Cố Gắng Thêm!',
                            style: TextStyle(
                              color: AppColors.eel,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.milestoneName,
                            style: TextStyle(
                              color: AppColors.wolf,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Stars ───────────────────────────────────────
                    FadeInUp(
                      duration: const Duration(milliseconds: 700),
                      delay: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.snow,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: glowColor.withOpacity(0.15),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            StarDisplayWidget(
                              stars: result.totalStars,
                              size: 56,
                              animate: true,
                            ),
                            const SizedBox(height: 12),
                            if (isNewRecord)
                              FadeIn(
                                delay: const Duration(milliseconds: 1200),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 5),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: themeColors),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    '🏆 KỶ LỤC MỚI!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Stats grid ──────────────────────────────────
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 400),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.bolt,
                              label: 'Điểm',
                              value: '${result.score}',
                              color: const Color(0xFFFFC107),
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (isArcade)
                            Expanded(
                              child: _StatCard(
                                icon: Icons.timer_rounded,
                                label: 'Thời gian',
                                value: _formatTime(result.timeSpentMs),
                                color: const Color(0xFF00BCD4),
                              ),
                            )
                          else
                            Expanded(
                              child: _StatCard(
                                icon: Icons.error_outline_rounded,
                                label: 'Số lỗi',
                                value: '${result.mistakesCount}',
                                color: const Color(0xFFE91E63),
                              ),
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.monetization_on_rounded,
                              label: 'Xu thưởng',
                              value: result.rewardedCoins > 0
                                  ? '+${result.rewardedCoins}'
                                  : '0',
                              color: const Color(0xFF43A047),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Coins reward banner ─────────────────────────
                    if (result.rewardedCoins > 0)
                      FadeIn(
                        delay: const Duration(milliseconds: 800),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFFFC107).withOpacity(0.2),
                                const Color(0xFF43A047).withOpacity(0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFFFC107).withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Text('🪙', style: TextStyle(fontSize: 28)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '+${result.rewardedCoins} xu được thưởng!',
                                      style: TextStyle(
                                        color: AppColors.eel,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      'Bạn đã cải thiện số sao, thưởng thêm xu!',
                                      style: TextStyle(
                                        color: AppColors.wolf,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // ── Action buttons ──────────────────────────────
                    FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 600),
                      child: Column(
                        children: [
                          // Chơi lại
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider(
                                      create: (_) => sl<MiniGameBloc>(),
                                      child: MiniGamePlayPage(
                                        partId: widget.partId,
                                        gameType: widget.gameType,
                                        milestoneName: widget.milestoneName,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text(
                                'CHƠI LẠI',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColors[0],
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Về trang chủ
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Về trang chủ bằng cách pop trang result (đã pushReplacement trước đó)
                                if (Navigator.of(context).canPop()) {
                                  Navigator.of(context).pop();
                                }
                              },
                              icon: Icon(Icons.home_rounded, color: AppColors.eel),
                              label: Text('VỀ TRANG CHỦ', style: TextStyle(color: AppColors.eel, fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: AppColors.border, width: 2),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: AppColors.eel,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: AppColors.wolf,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
