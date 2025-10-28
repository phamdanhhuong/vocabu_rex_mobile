import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/streak/ui/blocs/streak_bloc.dart';
import 'streak_tokens.dart';

class StreakHeader extends StatelessWidget {
  const StreakHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StreakBloc, StreakState>(
      builder: (context, state) {
        int streakCount = 0;
        bool isFrozen = false;
        if (state is StreakLoaded) {
          streakCount = state.response.currentStreak.length;
          isFrozen = state.response.currentStreak.isCurrentlyFrozen;
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
            tpNumber.height + kHeaderTextGap + tpLabel.height;

        return Container(
          // margin: const EdgeInsets.symmetric(horizontal: kStreakHorizontalGutter),
          color: accent,
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
                        Text('$streakCount', style: numberStyle),
                        const SizedBox(height: kHeaderTextGap),
                        Text('ngày streak!', style: labelStyle),
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
                            size: combinedTextHeight.clamp(kHeaderImageMinSize, kHeaderImageMaxSize),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(
                  horizontal: kStreakHorizontalGutter,
                ),
                padding: const EdgeInsets.all(kInfoPanelPadding),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(kInfoPanelBorderRadius),
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
            ],
          ),
        );
      },
    );
  }
}
