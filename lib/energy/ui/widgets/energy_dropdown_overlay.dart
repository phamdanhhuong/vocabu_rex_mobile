import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/energy_bloc.dart';

class EnergyDropdownOverlay extends StatelessWidget {
  final VoidCallback onClose;
  final int currentEnergy;
  final int maxEnergy;
  final String timeUntilNextRecharge;
  final int gemCost;
  final int coinCost;
  final int gemsBalance;
  final int coinsBalance;

  const EnergyDropdownOverlay({
    Key? key,
    required this.onClose,
    required this.currentEnergy,
    required this.maxEnergy,
    required this.timeUntilNextRecharge,
    required this.gemCost,
    required this.coinCost,
    required this.gemsBalance,
    required this.coinsBalance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final energyNeeded = maxEnergy - currentEnergy;
    final gemsNeeded = energyNeeded * gemCost;
    final coinsNeeded = energyNeeded * coinCost;
    final canAffordGems = gemsBalance >= gemsNeeded;
    final canAffordCoins = coinsBalance >= coinsNeeded;

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF1F1F1F),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt, color: Colors.yellow, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Năng lượng',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onClose,
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),

          // Energy Progress Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$currentEnergy / $maxEnergy',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      timeUntilNextRecharge,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: currentEnergy / maxEnergy,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.yellow,
                  ),
                  minHeight: 8,
                ),
              ],
            ),
          ),

          // Refill Options
          if (energyNeeded > 0) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SẠC ĐẦY',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Gem Option
                  _buildRefillOption(
                    context: context,
                    icon: Icons.diamond,
                    iconColor: Colors.blueAccent,
                    title: 'Sử dụng Gem',
                    cost: gemsNeeded,
                    balance: gemsBalance,
                    canAfford: canAffordGems,
                    onTap: () => _buyEnergy(context, energyNeeded, 'GEMS'),
                  ),

                  const SizedBox(height: 8),

                  // Coin Option
                  _buildRefillOption(
                    context: context,
                    icon: Icons.monetization_on,
                    iconColor: Colors.orange,
                    title: 'Sử dụng Coin',
                    cost: coinsNeeded,
                    balance: coinsBalance,
                    canAfford: canAffordCoins,
                    onTap: () => _buyEnergy(context, energyNeeded, 'COINS'),
                  ),

                  const SizedBox(height: 8),

                  // Review Option
                  _buildRefillOption(
                    context: context,
                    icon: Icons.refresh,
                    iconColor: Colors.green,
                    title: 'Ôn tập để hồi năng lượng',
                    onTap: () => _review(context),
                  ),
                ],
              ),
            ),
          ] else ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Năng lượng đã đầy!',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRefillOption({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    int? cost,
    int? balance,
    bool? canAfford,
    required VoidCallback onTap,
  }) {
    final isEnabled = canAfford ?? true;
    final showCostInfo = cost != null && balance != null;

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isEnabled ? Colors.grey[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isEnabled ? Colors.grey[300]! : Colors.grey[200]!,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isEnabled ? Colors.black : Colors.grey[500],
                    ),
                  ),
                  if (showCostInfo)
                    Text(
                      '$cost (Còn: $balance)',
                      style: TextStyle(
                        fontSize: 12,
                        color: isEnabled ? Colors.grey[600] : Colors.grey[400],
                      ),
                    ),
                ],
              ),
            ),
            if (canAfford != null && !canAfford)
              Icon(Icons.lock, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  void _buyEnergy(
    BuildContext context,
    int energyAmount,
    String paymentMethod,
  ) {
    context.read<EnergyBloc>().add(
      BuyEnergyEvent(energyAmount: energyAmount, paymentMethod: paymentMethod),
    );
  }

  void _review(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/exercise',
      arguments: {'lessonId': "review", 'lessonTitle': "Ôn tập"},
    );
  }
}
