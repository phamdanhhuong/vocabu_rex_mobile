import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

import 'onboarding_header.dart';
import 'duo_character_with_speech.dart';
import 'components/onboarding_option_tile.dart';
import 'onboarding_continue_button.dart';

class LevelSelectionScreen extends StatefulWidget {
  final Function(String) onLevelSelected;
  final VoidCallback? onBack;

  const LevelSelectionScreen({
    super.key,
    required this.onLevelSelected,
    this.onBack,
  });

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen>
    with SingleTickerProviderStateMixin {
  String selectedLevel = '';
  late AnimationController _animationController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  final List<Map<String, dynamic>> levels = [
    {'title': 'Tôi mới học tiếng Anh', 'level': 1},
    {'title': 'Tôi biết một vài từ thông dụng', 'level': 2},
    {'title': 'Tôi có thể giao tiếp cơ bản', 'level': 3},
    {'title': 'Tôi có thể nói về nhiều chủ đề', 'level': 4},
    {'title': 'Tôi có thể đi sâu vào hầu hết các chủ đề', 'level': 5},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _fadeAnimations = List.generate(
      levels.length,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.12,
            0.5 + (index * 0.12),
            curve: Curves.easeIn,
          ),
        ),
      ),
    );

    _slideAnimations = List.generate(
      levels.length,
      (index) => Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.12,
            0.5 + (index * 0.12),
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
    return Scaffold(
      backgroundColor: AppColors.polar,
      body: SafeArea(
        child: Column(
          children: [
            OnboardingHeader(
              currentStep: 2,
              totalSteps: 10,
              onBack: widget.onBack,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    DuoCharacterWithSpeech(
                      message: 'Trình độ tiếng Anh của bạn ở mức nào?',
                    ),
                    SizedBox(height: 32.h),
                    _buildLevelList(),
                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ),
            OnboardingContinueButton(
              text: 'TIẾP TỤC',
              isEnabled: selectedLevel.isNotEmpty,
              onPressed: selectedLevel.isNotEmpty
                  ? () => widget.onLevelSelected(selectedLevel)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelList() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        children: levels.asMap().entries.map((entry) {
          final index = entry.key;
          final level = entry.value;
          final isSelected = selectedLevel == level['title'];
          
          return SlideTransition(
            position: _slideAnimations[index],
            child: FadeTransition(
              opacity: _fadeAnimations[index],
              child: LevelTile(
                title: level['title'] as String,
                level: level['level'] as int,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    selectedLevel = level['title'] as String;
                  });
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}