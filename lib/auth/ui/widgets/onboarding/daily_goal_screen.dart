import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'components/duo_with_speech.dart';
import 'components/duo_character.dart';
import 'components/goal_option_tile.dart';

class DailyGoalScreen extends StatelessWidget {
  final String? selectedGoal;
  final Function(String) onGoalSelected;

  const DailyGoalScreen({
    super.key,
    this.selectedGoal,
    required this.onGoalSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Fixed header section
        _buildFixedHeader(),
        
        // Scrollable content
        Expanded(
          child: _buildScrollableContent(),
        ),
      ],
    );
  }

  Widget _buildFixedHeader() {
    return DuoWithSpeechFactory.horizontal(
      speechText: 'Chọn mục tiêu học tập hàng ngày của bạn!',
      duoType: DuoCharacterType.happy,
    );
  }

  Widget _buildScrollableContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildGoalsList(),
        ],
      ),
    );
  }

  Widget _buildGoalsList() {
    final goals = [
      ('5', '5 phút/ngày', 'Thư giãn', 'casual', Colors.green),
      ('10', '10 phút/ngày', 'Đều đặn', 'regular', Colors.blue),
      ('15', '15 phút/ngày', 'Nghiêm túc', 'serious', Colors.orange),
      ('20', '20 phút/ngày', 'Cường độ cao', 'intense', Colors.red),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        children: goals.map((goal) {
          return Column(
            children: [
              GoalOptionTile(
                time: goal.$1,
                title: goal.$2,
                subtitle: goal.$3,
                difficulty: goal.$3,
                difficultyColor: goal.$5,
                isSelected: selectedGoal == goal.$4,
                onTap: () => onGoalSelected(goal.$4),
              ),
              SizedBox(height: 16.h),
            ],
          );
        }).toList(),
      ),
    );
  }
}