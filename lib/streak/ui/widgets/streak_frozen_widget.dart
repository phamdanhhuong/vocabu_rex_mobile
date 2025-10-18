import 'package:flutter/material.dart';

class StreakFrozenWidget extends StatelessWidget {
  final bool isFrozen;
  final int freezesRemaining;
  final VoidCallback? onExtendStreak;

  const StreakFrozenWidget({
    Key? key,
    required this.isFrozen,
    this.freezesRemaining = 0,
    this.onExtendStreak,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
  if (!isFrozen) return SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.blueAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  freezesRemaining > 0
                      ? 'Streak frozen yesterday. You have $freezesRemaining freeze(s) left. Extend your streak now!'
                      : 'Streak frozen yesterday. You have no freezes left.',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: freezesRemaining > 0 ? onExtendStreak : null,
              child: Text('EXTEND STREAK', style: TextStyle(color: freezesRemaining > 0 ? Colors.blueAccent : Colors.grey, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
