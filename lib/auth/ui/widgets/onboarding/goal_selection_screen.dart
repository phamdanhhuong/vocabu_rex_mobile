import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'components/duo_with_speech.dart';
import 'components/duo_character.dart';
import 'components/goal_tile.dart';

class GoalSelectionScreen extends StatefulWidget {
  final Function(List<String>) onGoalsSelected;

  const GoalSelectionScreen({
    super.key,
    required this.onGoalsSelected,
  });

  @override
  State<GoalSelectionScreen> createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  List<String> selectedGoals = [];

  final List<Map<String, dynamic>> goals = [
    {
      'id': 'connect',
      'icon': Icons.people,
      'title': 'Kết nối với mọi người',
      'description': 'Giao tiếp và làm quen bạn bè mới',
    },
    {
      'id': 'travel',
      'icon': Icons.flight,
      'title': 'Chuẩn bị đi du lịch',
      'description': 'Tự tin khi đi du lịch nước ngoài',
    },
    {
      'id': 'study',
      'icon': Icons.school,
      'title': 'Hỗ trợ việc học tập',
      'description': 'Nâng cao kết quả học tập',
    },
    {
      'id': 'entertainment',
      'icon': Icons.celebration,
      'title': 'Giải trí',
      'description': 'Thưởng thức phim, nhạc, sách tiếng Anh',
    },
    {
      'id': 'career',
      'icon': Icons.work,
      'title': 'Phát triển sự nghiệp',
      'description': 'Tăng cơ hội thăng tiến trong công việc',
    },
    {
      'id': 'hobby',
      'icon': Icons.psychology,
      'title': 'Tận dụng thời gian rảnh',
      'description': 'Học hỏi điều mới mẻ và bổ ích',
    },
  ];

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
    return Column(
      children: [
        SizedBox(height: 60.h),
        DuoWithSpeechFactory.horizontal(
          duoType: DuoCharacterType.withGrad,
          speechText: 'Đó đều là những lý do học tập tuyệt vời!',
        ),
        SizedBox(height: 40.h),
      ],
    );
  }

  Widget _buildScrollableContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildGoalList(),
          SizedBox(height: 32.h), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildGoalList() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: goals.map((goal) {
          final isSelected = selectedGoals.contains(goal['id']);
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: GoalTile(
              icon: goal['icon'],
              title: goal['title'],
              description: goal['description'],
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedGoals.remove(goal['id']);
                  } else {
                    selectedGoals.add(goal['id']);
                  }
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}