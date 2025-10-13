import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/energy_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CurrentEnergyWidget extends StatelessWidget {
  final VoidCallback? onTapEnergy;

  const CurrentEnergyWidget({
    Key? key,
    this.onTapEnergy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EnergyBloc, EnergyState>(
      builder: (context, state) {
        if (state is EnergyLoaded) {
          final energy = state.response.currentEnergy;
          final maxEnergy = state.response.maxEnergy;
          return GestureDetector(
            onTap: onTapEnergy,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade400,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/icons/energy.svg',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 4),
                  Text('$energy/$maxEnergy', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          );
        } else if (state is EnergyLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is EnergyError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
