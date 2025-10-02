import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';
import 'onboarding_header.dart';
import 'duo_character_with_speech.dart';
import 'language_option_tile.dart';
import 'onboarding_continue_button.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final Function(String) onLanguageSelected;

  const LanguageSelectionScreen({
    super.key,
    required this.onLanguageSelected,
  });

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String selectedLanguage = '';

  final List<Map<String, String>> languages = [
    {'flag': '🇺🇸', 'name': 'Tiếng Anh'},
    {'flag': '🇨🇳', 'name': 'Tiếng Hoa'},
    {'flag': '🇮🇹', 'name': 'Tiếng Ý'},
    {'flag': '🇫🇷', 'name': 'Tiếng Pháp'},
    {'flag': '🇰🇷', 'name': 'Tiếng Hàn'},
    {'flag': '🇯🇵', 'name': 'Tiếng Nhật'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2B3A4A),
      body: SafeArea(
        child: Column(
          children: [
            // Progress header
            OnboardingHeader(
              currentStep: 1,
              totalSteps: 10,
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20.h),

                    // Duo character with speech
                    DuoCharacterWithSpeech(
                      message: 'Bạn muốn học gì\nnhỉ?',
                    ),

                    SizedBox(height: 32.h),

                    // Language selection header
                    _buildLanguageHeader(),

                    SizedBox(height: 16.h),

                    // Language options
                    _buildLanguageList(),

                    SizedBox(height: 100.h), // Extra space for button
                  ],
                ),
              ),
            ),

            // Continue button (fixed at bottom)
            OnboardingContinueButton(
              text: 'TIẾP TỤC',
              isEnabled: selectedLanguage.isNotEmpty,
              onPressed: selectedLanguage.isNotEmpty
                  ? () => widget.onLanguageSelected(selectedLanguage)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          Text(
            'Dành cho người nói tiếng Việt',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          Spacer(),
          Icon(
            Icons.keyboard_arrow_up,
            color: AppColors.textGray,
            size: 20.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageList() {
    return Column(
      children: languages.map((language) {
        final isSelected = selectedLanguage == language['name'];
        return LanguageOptionTile(
          flagEmoji: language['flag']!,
          languageName: language['name']!,
          isSelected: isSelected,
          onTap: () {
            setState(() {
              selectedLanguage = language['name']!;
            });
          },
        );
      }).toList(),
    );
  }
}