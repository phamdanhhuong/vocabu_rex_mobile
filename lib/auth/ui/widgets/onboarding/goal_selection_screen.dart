import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'onboarding_header.dart';
import 'duo_character_with_speech.dart';
import 'goal_option_tile.dart';
import 'onboarding_continue_button.dart';

class GoalSelectionScreen extends StatefulWidget {
  final Function(List<String>) onGoalsSelected;
  final VoidCallback? onBack;

  const GoalSelectionScreen({
    super.key,
    required this.onGoalsSelected,
    this.onBack,
  });

  @override
  State<GoalSelectionScreen> createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  List<String> selectedGoals = [];

  final List<Map<String, dynamic>> goals = [
    {'icon': Icons.people, 'title': 'Kết nối với mọi người'},
    {'icon': Icons.flight, 'title': 'Chuẩn bị đi du lịch'},
    {'icon': Icons.school, 'title': 'Hỗ trợ việc học tập'},
    {'icon': Icons.celebration, 'title': 'Giải trí'},
    {'icon': Icons.work, 'title': 'Phát triển sự nghiệp'},
    {'icon': Icons.psychology, 'title': 'Tận dụng thời gian rảnh'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2B3A4A),
      body: SafeArea(
        child: Column(
          children: [
            // Progress header with back button
            OnboardingHeader(
              currentStep: 3,
              totalSteps: 10,
              onBack: widget.onBack,
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20.h),

                    // Duo character with speech
                    DuoCharacterWithSpeech(
                      message: 'Đó đều là những lý do học tập tuyệt vời!',
                    ),

                    SizedBox(height: 32.h),

                    // Goal options
                    _buildGoalList(),

                    SizedBox(height: 100.h), // Extra space for button
                  ],
                ),
              ),
            ),

            // Continue button (fixed at bottom)
            OnboardingContinueButton(
              text: 'TIẾP TỤC',
              isEnabled: selectedGoals.isNotEmpty,
              onPressed: selectedGoals.isNotEmpty
                  ? () => widget.onGoalsSelected(selectedGoals)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalList() {
    return Column(
      children: goals.map((goal) {
        final isSelected = selectedGoals.contains(goal['title']);
        return GoalOptionTile(
          icon: goal['icon'],
          title: goal['title'],
          isSelected: isSelected,
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedGoals.remove(goal['title']);
              } else {
                selectedGoals.add(goal['title']);
              }
            });
          },
        );
      }).toList(),
    );
  }
}