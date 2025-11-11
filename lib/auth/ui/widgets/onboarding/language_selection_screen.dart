import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'components/duo_with_speech.dart';
import 'components/duo_character.dart';
import 'components/onboarding_option_tile.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final Function(String) onLanguageSelected;

  const LanguageSelectionScreen({
    super.key,
    required this.onLanguageSelected,
  });

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with SingleTickerProviderStateMixin {
  String selectedLanguage = '';
  late AnimationController _animationController;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _fadeAnimations;

  final List<Map<String, String>> languages = [
    {'flag': '🇺🇸', 'name': 'Tiếng Anh'},
    {'flag': '🇨🇳', 'name': 'Tiếng Hoa'},
    {'flag': '🇮🇹', 'name': 'Tiếng Ý'},
    {'flag': '🇫🇷', 'name': 'Tiếng Pháp'},
    {'flag': '🇰🇷', 'name': 'Tiếng Hàn'},
    {'flag': '🇯🇵', 'name': 'Tiếng Nhật'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Create staggered slide-in animations
    _slideAnimations = List.generate(
      languages.length,
      (index) => Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.1,
            0.6 + (index * 0.1),
            curve: Curves.easeOut,
          ),
        ),
      ),
    );

    // Create fade animations
    _fadeAnimations = List.generate(
      languages.length,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.1,
            0.6 + (index * 0.1),
            curve: Curves.easeIn,
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
      children: languages.asMap().entries.map((entry) {
        final index = entry.key;
        final language = entry.value;
        final isSelected = selectedLanguage == language['name'];
        
        return SlideTransition(
          position: _slideAnimations[index],
          child: FadeTransition(
            opacity: _fadeAnimations[index],
            child: LanguageTile(
              flagEmoji: language['flag']!,
              languageName: language['name']!,
              isSelected: isSelected,
              onTap: () => _onLanguageSelected(language['name']!),
            ),
          ),
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