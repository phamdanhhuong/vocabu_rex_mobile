import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';
import 'package:vocabu_rex_mobile/currency/ui/widgets/current_currency_widget.dart';
import 'package:vocabu_rex_mobile/streak/ui/widgets/current_streak_widget.dart';
import 'package:vocabu_rex_mobile/energy/ui/widgets/current_energy_widget.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {

  const HomeAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.appBarColor,
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CurrentStreakWidget(),
                CurrentCurrencyWidget(),
                CurrentEnergyWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
