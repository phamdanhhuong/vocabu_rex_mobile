import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/streak_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CurrentStreakWidget extends StatelessWidget {
  final VoidCallback? onTapStreak;

  const CurrentStreakWidget({
    Key? key,
    this.onTapStreak,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StreakBloc, StreakState>(
      builder: (context, state) {
        if (state is StreakLoaded) {
          final streak = state.response.currentStreak.length;
          return GestureDetector(
            onTap: onTapStreak,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/streak.svg',
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 4),
                Text('$streak', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
              ],
            ),
          );
        } else if (state is StreakLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is StreakError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
