import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'components/duo_with_speech.dart';
import 'components/duo_character.dart';
import 'components/onboarding_option_tile.dart';

class GoalSelectionScreen extends StatefulWidget {
  final Function(List<String>) onGoalsSelected;

  const GoalSelectionScreen({
    super.key,
    required this.onGoalsSelected,
  });

  @override
  State<GoalSelectionScreen> createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen>
    with SingleTickerProviderStateMixin {
  List<String> selectedGoals = [];
  late AnimationController _animationController;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _scaleAnimations;

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
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Staggered slide animations
    _slideAnimations = List.generate(
      goals.length,
      (index) => Tween<Offset>(
        begin: const Offset(-1.0, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.08,
            0.5 + (index * 0.08),
            curve: Curves.easeOut,
          ),
        ),
      ),
    );

    // Scale animations
    _scaleAnimations = List.generate(
      goals.length,
      (index) => Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.08,
            0.5 + (index * 0.08),
            curve: Curves.easeOut,
          ),
        ),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
        children: goals.asMap().entries.map((entry) {
          final index = entry.key;
          final goal = entry.value;
          final isSelected = selectedGoals.contains(goal['id']);
          
          return SlideTransition(
            position: _slideAnimations[index],
            child: ScaleTransition(
              scale: _scaleAnimations[index],
              child: Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: GoalSelectionTile(
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
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}