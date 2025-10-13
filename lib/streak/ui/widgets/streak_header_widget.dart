import 'package:flutter/material.dart';

class StreakHeaderWidget extends StatelessWidget {
  final int streakDays;
  final int tabIndex;
  final Function(int) onTabChanged;

  const StreakHeaderWidget({
    Key? key,
    required this.streakDays,
    required this.tabIndex,
    required this.onTabChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE3F3FF),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      '$streakDays day streak',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6EC6FF),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.local_fire_department, color: Colors.orange, size: 32),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _TabButton(
                label: 'PERSONAL',
                selected: tabIndex == 0,
                onTap: () => onTabChanged(0),
              ),
              _TabButton(
                label: 'FRIENDS',
                selected: tabIndex == 1,
                onTap: () => onTabChanged(1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? Colors.blueAccent : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: selected ? Colors.blueAccent : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
