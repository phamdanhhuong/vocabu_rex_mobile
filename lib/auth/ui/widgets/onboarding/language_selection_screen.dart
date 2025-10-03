import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';
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
        SizedBox(height: 20.h),
        _buildDuoCharacter(),
        SizedBox(height: 40.h),
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
          SizedBox(height: 32.h), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildDuoCharacter() {
    return Container(
      width: 120.w,
      height: 120.h,
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(60.w),
        border: Border.all(color: Colors.grey[800]!, width: 4),
      ),
      child: Stack(
        children: [
          // Main head
          Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(60.w),
            ),
          ),
          // Eyes
          _buildEye(left: 25.w),
          _buildEye(right: 25.w),
          // Beak
          Positioned(
            left: 52.w,
            top: 65.h,
            child: Container(
              width: 16.w,
              height: 12.h,
              decoration: const BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEye({double? left, double? right}) {
    return Positioned(
      left: left,
      right: right,
      top: 35.h,
      child: Container(
        width: 18.w,
        height: 25.h,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Center(
          child: Container(
            width: 8.w,
            height: 12.h,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
          ),
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
          const Spacer(),
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