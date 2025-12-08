import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/lesson_header.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/home_bloc.dart';
import 'package:vocabu_rex_mobile/streak/ui/blocs/streak_bloc.dart';
import 'package:vocabu_rex_mobile/currency/ui/blocs/currency_bloc.dart';
import 'package:vocabu_rex_mobile/energy/ui/blocs/energy_bloc.dart';
import '../../../theme/colors.dart'; // Đảm bảo đường dẫn này chính xác

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {

  const HomeAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    // Use BlocBuilders to read real data from app state and pass them into
    // LessonHeader. If a bloc is still loading or in an error state, default
    // to sensible zeros.
    return Container(
      color: AppColors.background, 
      height: preferredSize.height,
      child: SafeArea(
        bottom: false,
        child: BlocBuilder<HomeBloc, HomeState>(builder: (context, homeState) {
          int courseProgress = 0;
          int completionPercentage = 0;
          // String flagAsset = 'assets/flags/english.png';
          if (homeState is HomeSuccess) {
            courseProgress = homeState.userProgressEntity.levelReached;
            completionPercentage = homeState.userProgressEntity.completionPercentage;
            // TODO: derive flagAsset from user profile / locale when available
          }

          return BlocBuilder<StreakBloc, StreakState>(builder: (context, streakState) {
            int streakCount = 0;
            if (streakState is StreakLoaded) {
              streakCount = streakState.response.currentStreak.length;
            }

            return BlocBuilder<CurrencyBloc, CurrencyState>(builder: (context, currencyState) {
              int gems = 0;
              int coins = 0;
              if (currencyState is CurrencyLoaded) {
                gems = currencyState.balance.gems;
                coins = currencyState.balance.coins;
              }

              return BlocBuilder<EnergyBloc, EnergyState>(builder: (context, energyState) {
                int hearts = 0; // map energy to heartCount
                if (energyState is EnergyLoaded) {
                  // Use currentEnergy as hearts display
                  hearts = energyState.response.currentEnergy;
                }

                return LessonHeader(
                  // flagAssetPath: flagAsset,
                  courseProgress: courseProgress,
                  completionPercentage: completionPercentage,
                  streakCount: streakCount,
                  gemCount: gems,
                  coinCount: coins,
                  heartCount: hearts,
                );
              });
            });
          });
        }),
      ),
    );
  }
}
