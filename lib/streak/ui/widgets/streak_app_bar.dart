import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/streak/ui/blocs/streak_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'streak_tokens.dart';

class StreakAppBar extends StatefulWidget {
  const StreakAppBar({super.key});

  @override
  State<StreakAppBar> createState() => _StreakAppBarState();
}

class _StreakAppBarState extends State<StreakAppBar> {

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StreakBloc, StreakState>(
      builder: (context, state) {
        Color accent;
        if (state is StreakLoaded) {
          final isFrozen = state.response.currentStreak.isCurrentlyFrozen;
          final length = state.response.currentStreak.length;
          if (isFrozen) {
            accent = AppColors.macaw;
          } else if (length > 0) {
            accent = AppColors.fox;
          } else {
            accent = AppColors.wolf;
          }
        } else {
          accent = AppColors.wolf;
        }

        final titleTextColor = accent == AppColors.wolf
            ? Colors.black
            : Colors.white;

        return Container(
          decoration: BoxDecoration(
            gradient: state is StreakLoaded && state.response.currentStreak.isCurrentlyFrozen
                ? const LinearGradient(
                    colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : ((state is StreakLoaded && state.response.currentStreak.length > 0)
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
          padding: const EdgeInsets.only(
            top: kAppBarTopPadding,
            bottom: kAppBarBottomPadding,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: kStreakHorizontalGutter,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: kCloseButtonSize,
                        height: kCloseButtonSize,
                        decoration: BoxDecoration(
                          color: titleTextColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: accent,
                          size: kCloseIconSize,
                        ),
                      ),
                    ),
                    Text(
                      'Streak',
                      style: TextStyle(
                        color: titleTextColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      width: kCloseButtonSize,
                      height: kCloseButtonSize,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
