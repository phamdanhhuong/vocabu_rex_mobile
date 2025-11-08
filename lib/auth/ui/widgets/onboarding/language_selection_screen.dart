import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'components/duo_with_speech.dart';
import 'components/duo_character.dart';
import 'language_option_tile.dart';

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
          duoType: DuoCharacterType.normal,
          speechText: 'Bạn muốn học gì nhỉ?',
        ),
      ],
    );
  }

  Widget _buildScrollableContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildLanguageHeader(),
          SizedBox(height: 16.h),
          _buildLanguageList(),
        ],
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
              color: AppColors.snow,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.keyboard_arrow_up,
            color: AppColors.wolf,
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
          onTap: () => _onLanguageSelected(language['name']!),
        );
      }).toList(),
    );
  }

  void _onLanguageSelected(String language) {
    setState(() {
      selectedLanguage = language;
    });
    widget.onLanguageSelected(language);
  }
}