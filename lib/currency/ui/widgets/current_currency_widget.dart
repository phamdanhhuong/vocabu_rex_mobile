import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/currency_bloc.dart';

class CurrentCurrencyWidget extends StatelessWidget {
  final VoidCallback? onTapGems;
  final VoidCallback? onTapCoins;

  const CurrentCurrencyWidget({
    Key? key,
    this.onTapGems,
    this.onTapCoins,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrencyBloc, CurrencyState>(
      builder: (context, state) {
        if (state is CurrencyLoaded) {
          final gems = state.balance.gems;
          final coins = state.balance.coins;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: onTapGems,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.diamond, color: Colors.blueAccent),
                      const SizedBox(width: 4),
                      Text('$gems', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: onTapCoins,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.monetization_on, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text('$coins', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          );
        } else if (state is CurrencyLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CurrencyError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
