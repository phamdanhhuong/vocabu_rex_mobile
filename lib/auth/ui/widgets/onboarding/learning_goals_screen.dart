import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'components/duo_with_speech.dart';
import 'components/duo_character.dart';
import 'components/goal_tile.dart';

class LearningGoalsScreen extends StatefulWidget {
  final List<String> selectedGoals;
  final Function(String) onGoalToggled;

  const LearningGoalsScreen({
    super.key,
    required this.selectedGoals,
    required this.onGoalToggled,
  });

  @override
  LearningGoalsScreenState createState() => LearningGoalsScreenState();
}

class LearningGoalsScreenState extends State<LearningGoalsScreen> {
  final List<Map<String, dynamic>> goals = [
    {
      'id': 'conversation',
      'icon': Icons.chat_bubble_outline,
      'title': 'Giao tiếp hàng ngày',
      'description': 'Học từ vựng và cụm từ thông dụng',
    },
    {
      'id': 'business',
      'icon': Icons.business_center_outlined,
      'title': 'Tiếng Anh công sở',
      'description': 'Phát triển kỹ năng giao tiếp trong công việc',
    },
    {
      'id': 'travel',
      'icon': Icons.flight_takeoff_outlined,
      'title': 'Du lịch',
      'description': 'Từ vựng và câu hỏi hữu ích khi đi du lịch',
    },
    {
      'id': 'academic',
      'icon': Icons.school_outlined,
      'title': 'Học thuật',
      'description': 'Chuẩn bị cho các kỳ thi và nghiên cứu',
    },
    {
      'id': 'entertainment',
      'icon': Icons.movie_outlined,
      'title': 'Giải trí',
      'description': 'Hiểu phim, nhạc và nội dung giải trí',
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
        DuoWithSpeechFactory.horizontal(
          duoType: DuoCharacterType.withGrad,
          speechText: 'Bạn muốn học tiếng Anh để làm gì?',
        ),
      ],
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: goals.map((goal) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: GoalTile(
              icon: goal['icon'],
              title: goal['title'],
              description: goal['description'],
              isSelected: widget.selectedGoals.contains(goal['id']),
              onTap: () {
                widget.onGoalToggled(goal['id']);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}