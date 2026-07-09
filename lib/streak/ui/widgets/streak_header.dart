import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/streak/ui/blocs/streak_bloc.dart';
import 'package:vocabu_rex_mobile/shop/ui/blocs/shop_bloc.dart';
import 'streak_tokens.dart';

class StreakHeader extends StatelessWidget {
  const StreakHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final shopState = context.watch<ShopBloc>().state;
    final freezesRemaining = shopState.inventory
        .where((e) => e.item.category == 'STREAK_FREEZE')
        .fold(0, (sum, inv) => sum + inv.quantity);

    return BlocBuilder<StreakBloc, StreakState>(
      builder: (context, state) {
        int streakCount = 0;
        bool isFrozen = false;
        bool isLongest = false;
        if (state is StreakLoaded) {
          streakCount = state.response.currentStreak.length;
          isFrozen = state.response.currentStreak.isCurrentlyFrozen;
          // compute longest historical streak (compare durations)
          final maxPast = state.response.history.isNotEmpty
              ? state.response.history.map((e) => e.durationDays).reduce(max)
              : 0;
          isLongest = streakCount > 0 && streakCount >= maxPast;
        }

        final accent = isFrozen
            ? AppColors.macaw
            : (streakCount > 0 ? AppColors.fox : AppColors.wolf);
        final titleTextColor = accent == AppColors.wolf
            ? Colors.black
            : Colors.white;

        final numberStyle = TextStyle(
          color: titleTextColor,
          fontSize: kHeaderNumberFontSize,
          fontWeight: FontWeight.bold,
        );
        final labelStyle = TextStyle(
          color: titleTextColor,
          fontSize: kHeaderLabelFontSize,
          fontWeight: FontWeight.w600,
        );

        // Measure text heights to size the image to match visually.
        final tpNumber = TextPainter(
          text: TextSpan(text: '$streakCount', style: numberStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        final tpLabel = TextPainter(
          text: TextSpan(text: 'ngày streak!', style: labelStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        final combinedTextHeight =
            tpNumber.height + kHeaderTextGap + tpLabel.height + 24;

        return Container(
          // margin: const EdgeInsets.symmetric(horizontal: kStreakHorizontalGutter),
          decoration: BoxDecoration(
            gradient: isFrozen
                ? const LinearGradient(
                    colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : (streakCount > 0
                    ? const LinearGradient(
                        colors: [Color(0xFFFF5252), Color(0xFFFF9800)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFFBDBDBD), Color(0xFF757575)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )),
          ),
          padding: const EdgeInsets.all(kStreakInnerPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(
                  horizontal: kStreakHorizontalGutter,
                ),
                padding: const EdgeInsets.all(kInfoPanelPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Shimmer.fromColors(
                          baseColor: titleTextColor,
                          highlightColor: Colors.white,
                          period: const Duration(seconds: 2),
                          child: Text('$streakCount', style: numberStyle),
                        ),
                        const SizedBox(height: kHeaderTextGap),
                        Text('ngày streak!', style: labelStyle),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.ac_unit_rounded, color: titleTextColor.withOpacity(0.9), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '$freezesRemaining lần bảo vệ',
                              style: TextStyle(
                                color: titleTextColor.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // image asset for streak state
                    Builder(
                      builder: (_) {
                        final assetPath = isFrozen
                            ? 'assets/icons/streak_freeze_border.png'
                            : (streakCount > 0
                                  ? 'assets/icons/streak_border.png'
                                  : 'assets/icons/no_streak.png');
                        return Image.asset(
                          assetPath,
                          width: combinedTextHeight.clamp(
                            kHeaderImageMinSize,
                            kHeaderImageMaxSize,
                          ),
                          height: combinedTextHeight.clamp(
                            kHeaderImageMinSize,
                            kHeaderImageMaxSize,
                          ),
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) => Icon(
                            Icons.shield,
                            color: titleTextColor,
                            size: combinedTextHeight.clamp(
                              kHeaderImageMinSize,
                              kHeaderImageMaxSize,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              if (isFrozen) ...[
                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                    horizontal: kStreakHorizontalGutter,
                  ),
                  padding: const EdgeInsets.all(kInfoPanelPadding),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(kInfoPanelBorderRadius),
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: accent,
                        size: kInfoIconSize,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hôm qua streak của bạn đã được đóng băng.',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: kInfoFontSize,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tới lúc nối dài streak rồi!',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: kInfoFontSize,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'NỐI DÀI STREAK',
                              style: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.bold,
                                fontSize: kInfoFontSize,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (isLongest) ...[
                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                    horizontal: kStreakHorizontalGutter,
                  ),
                  padding: const EdgeInsets.all(kInfoPanelPadding),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(kInfoPanelBorderRadius),
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: AppColors.bee,
                        size: kInfoIconSize,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Bạn đang có chuỗi streak dài nhất từ trước tới nay!',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: kInfoFontSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
