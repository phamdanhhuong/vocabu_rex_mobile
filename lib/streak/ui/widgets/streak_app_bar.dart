import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/streak/ui/blocs/streak_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'streak_tokens.dart';

class StreakAppBar extends StatefulWidget {
  const StreakAppBar({Key? key}) : super(key: key);

  @override
  State<StreakAppBar> createState() => _StreakAppBarState();
}

class _StreakAppBarState extends State<StreakAppBar> {
  int _selectedIndex = 0; // 0 = Cá nhân, 1 = Bạn bè

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StreakBloc, StreakState>(builder: (context, state) {
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

      final titleTextColor = accent == AppColors.wolf ? Colors.black : Colors.white;

      return Container(
        color: accent,
        padding: const EdgeInsets.only(top: kAppBarTopPadding, bottom: kAppBarBottomPadding),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kStreakHorizontalGutter),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: kCloseButtonSize,
                      height: kCloseButtonSize,
                      decoration: BoxDecoration(color: titleTextColor, shape: BoxShape.circle),
                      child: Icon(Icons.close, color: accent, size: kCloseIconSize),
                    ),
                  ),
                  Text('Streak', style: TextStyle(color: titleTextColor, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(width: kCloseButtonSize, height: kCloseButtonSize),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(children: [_buildTabItem('CÁ NHÂN', 0), _buildTabItem('BẠN BÈ', 1)]),
          ],
        ),
      );
    });
  }

  Widget _buildTabItem(String title, int index) {
    final bool isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          padding: const EdgeInsets.only(bottom: kTabBottomBorderWidth * 6),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: isSelected ? Colors.white : Colors.transparent, width: kTabBottomBorderWidth)),
          ),
          child: Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }
}
