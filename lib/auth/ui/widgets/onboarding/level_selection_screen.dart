import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'onboarding_header.dart';
import 'duo_character_with_speech.dart';
import 'level_option_tile.dart';
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

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  String selectedLevel = '';

  final List<Map<String, String>> levels = [
    {
      'title': 'Tôi mới học tiếng Anh',
      'description': '',
    },
    {
      'title': 'Tôi biết một vài từ thông dụng',
      'description': '',
    },
    {
      'title': 'Tôi có thể giao tiếp cơ bản',
      'description': '',
    },
    {
      'title': 'Tôi có thể nói về nhiều chủ đề',
      'description': '',
    },
    {
      'title': 'Tôi có thể đi sâu vào hầu hết các chủ đề',
      'description': '',
    },
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
              currentStep: 2,
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
                      message: 'Trình độ tiếng Anh của bạn ở mức nào?',
                    ),

                    SizedBox(height: 32.h),

                    // Level options
                    _buildLevelList(),

                    SizedBox(height: 100.h), // Extra space for button
                  ],
                ),
              ),
            ),

            // Continue button (fixed at bottom)
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
    return Column(
      children: levels.map((level) {
        final isSelected = selectedLevel == level['title'];
        return LevelOptionTile(
          icon: Icons.signal_cellular_alt,
          title: level['title']!,
          description: level['description']!,
          isSelected: isSelected,
          onTap: () {
            setState(() {
              selectedLevel = level['title']!;
            });
          },
        );
      }).toList(),
    );
  }
}