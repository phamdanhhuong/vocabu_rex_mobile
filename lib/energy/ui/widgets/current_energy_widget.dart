import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/energy_bloc.dart';

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
        print('CurrentEnergyWidget state: $state');
        if (state is EnergyLoaded) {
          final energy = state.response.currentEnergy;
          final maxEnergy = state.response.maxEnergy;
          print('EnergyLoaded: $energy/$maxEnergy');
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
                  Icon(Icons.bolt, color: Colors.yellow, size: 24),
                  const SizedBox(width: 4),
                  Text('$energy/$maxEnergy', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          );
        } else if (state is EnergyLoading) {
          print('EnergyLoading');
          return const Center(child: CircularProgressIndicator());
        } else if (state is EnergyError) {
          print('EnergyError: ${state.message}');
          return Center(child: Text('Error: ${state.message}'));
        }
        print('EnergyState: $state');
        return const SizedBox.shrink();
      },
    );
  }
}
