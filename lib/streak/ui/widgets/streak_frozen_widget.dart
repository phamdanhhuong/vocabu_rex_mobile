import 'package:flutter/material.dart';

class StreakFrozenWidget extends StatelessWidget {
  final bool isFrozen;
  final VoidCallback? onExtendStreak;

  const StreakFrozenWidget({
    Key? key,
    required this.isFrozen,
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
                  'Streak frozen yesterday. Extend your streak now!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onExtendStreak,
              child: Text('EXTEND STREAK', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
