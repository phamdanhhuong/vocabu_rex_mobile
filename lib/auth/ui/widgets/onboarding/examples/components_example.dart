import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import '../components/animated_character.dart';
import '../components/onboarding_option_tile.dart';
import '../components/daily_goal_tile.dart';

/// Example file showing how to use refactored onboarding components
/// This file serves as a reference and can be deleted after understanding usage

class OnboardingComponentsExample extends StatefulWidget {
  const OnboardingComponentsExample({super.key});

  @override
  State<OnboardingComponentsExample> createState() =>
      _OnboardingComponentsExampleState();
}

class _OnboardingComponentsExampleState
    extends State<OnboardingComponentsExample> {
  String selectedLanguage = '';
  String selectedLevel = '';
  Set<String> selectedGoals = {};
  String selectedDailyGoal = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.polar,
      appBar: AppBar(
        title: const Text('Onboarding Components Demo'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. Animated Characters'),
            _buildCharactersDemo(),
            SizedBox(height: 32.h),
            
            _buildSectionTitle('2. Language Tiles'),
            _buildLanguageTilesDemo(),
            SizedBox(height: 32.h),
            
            _buildSectionTitle('3. Level Tiles'),
            _buildLevelTilesDemo(),
            SizedBox(height: 32.h),
            
            _buildSectionTitle('4. Goal Selection Tiles'),
            _buildGoalTilesDemo(),
            SizedBox(height: 32.h),
            
            _buildSectionTitle('5. Daily Goal Tiles'),
            _buildDailyGoalTilesDemo(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.eel,
        ),
      ),
    );
  }

  // ====================
  // 1. ANIMATED CHARACTERS DEMO
  // ====================
  Widget _buildCharactersDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Các trạng thái nhân vật:',
          style: TextStyle(fontSize: 14.sp, color: AppColors.wolf),
        ),
        SizedBox(height: 16.h),
        
        // Row of different character states
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _characterCard(CharacterState.normal, 'Normal'),
              SizedBox(width: 12.w),
              _characterCard(CharacterState.happy, 'Happy'),
              SizedBox(width: 12.w),
              _characterCard(CharacterState.withBook, 'With Book'),
              SizedBox(width: 12.w),
              _characterCard(CharacterState.withGrad, 'Graduate'),
              SizedBox(width: 12.w),
              _characterCard(CharacterState.excited, 'Excited'),
              SizedBox(width: 12.w),
              _characterCard(CharacterState.thinking, 'Thinking'),
            ],
          ),
        ),
        
        SizedBox(height: 16.h),
        
        // Usage example code
        _codeExample('''
// Sử dụng với predefined state
CharacterAnimations.forState(
  state: CharacterState.happy,
  width: 120,
  height: 120,
)

// Hoặc custom
AnimatedCharacter.lottie(
  animationPath: 'assets/animations/duo_happy.json',
  fallbackImagePath: 'assets/images/duo_happy.png',
  width: 120,
  height: 120,
)
        '''),
      ],
    );
  }

  Widget _characterCard(CharacterState state, String label) {
    return Column(
      children: [
        Container(
          width: 120.w,
          height: 120.w,
          decoration: BoxDecoration(
            color: AppColors.snow,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.swan),
          ),
          child: CharacterAnimations.forState(
            state: state,
            width: 100.w,
            height: 100.w,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: AppColors.wolf),
        ),
      ],
    );
  }

  // ====================
  // 2. LANGUAGE TILES DEMO
  // ====================
  Widget _buildLanguageTilesDemo() {
    final languages = [
      ('🇺🇸', 'Tiếng Anh'),
      ('🇫🇷', 'Tiếng Pháp'),
      ('🇯🇵', 'Tiếng Nhật'),
    ];

    return Column(
      children: [
        ...languages.map((lang) => LanguageTile(
              flagEmoji: lang.$1,
              languageName: lang.$2,
              isSelected: selectedLanguage == lang.$2,
              onTap: () => setState(() => selectedLanguage = lang.$2),
            )),
        SizedBox(height: 16.h),
        _codeExample('''
LanguageTile(
  flagEmoji: '🇺🇸',
  languageName: 'Tiếng Anh',
  isSelected: true,
  onTap: () {},
)
        '''),
      ],
    );
  }

  // ====================
  // 3. LEVEL TILES DEMO
  // ====================
  Widget _buildLevelTilesDemo() {
    final levels = [
      ('Tôi mới học tiếng Anh', 1),
      ('Tôi biết một vài từ thông dụng', 2),
      ('Tôi có thể giao tiếp cơ bản', 3),
    ];

    return Column(
      children: [
        ...levels.map((level) => LevelTile(
              title: level.$1,
              level: level.$2,
              isSelected: selectedLevel == level.$1,
              onTap: () => setState(() => selectedLevel = level.$1),
            )),
        SizedBox(height: 16.h),
        _codeExample('''
LevelTile(
  title: 'Tôi mới học tiếng Anh',
  level: 1, // 1-5 bars
  isSelected: true,
  onTap: () {},
)
        '''),
      ],
    );
  }

  // ====================
  // 4. GOAL TILES DEMO
  // ====================
  Widget _buildGoalTilesDemo() {
    final goals = [
      (Icons.people, 'Kết nối', 'Giao tiếp với bạn bè', 'connect'),
      (Icons.flight, 'Du lịch', 'Chuẩn bị đi du lịch', 'travel'),
      (Icons.work, 'Sự nghiệp', 'Phát triển công việc', 'career'),
    ];

    return Column(
      children: [
        ...goals.map((goal) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: GoalSelectionTile(
                icon: goal.$1,
                title: goal.$2,
                description: goal.$3,
                isSelected: selectedGoals.contains(goal.$4),
                onTap: () {
                  setState(() {
                    if (selectedGoals.contains(goal.$4)) {
                      selectedGoals.remove(goal.$4);
                    } else {
                      selectedGoals.add(goal.$4);
                    }
                  });
                },
              ),
            )),
        SizedBox(height: 16.h),
        _codeExample('''
GoalSelectionTile(
  icon: Icons.people,
  title: 'Kết nối',
  description: 'Giao tiếp với bạn bè',
  isSelected: true,
  onTap: () {},
)
        '''),
      ],
    );
  }

  // ====================
  // 5. DAILY GOAL TILES DEMO
  // ====================
  Widget _buildDailyGoalTilesDemo() {
    final dailyGoals = [
      ('5', '5 phút/ngày', 'Thư giãn', AppColors.primary, 'casual'),
      ('10', '10 phút/ngày', 'Đều đặn', AppColors.macaw, 'regular'),
      ('15', '15 phút/ngày', 'Nghiêm túc', AppColors.fox, 'serious'),
    ];

    return Column(
      children: [
        ...dailyGoals.map((goal) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: DailyGoalTile(
                time: goal.$1,
                title: goal.$2,
                subtitle: '',
                difficulty: goal.$3,
                difficultyColor: goal.$4,
                isSelected: selectedDailyGoal == goal.$5,
                onTap: () => setState(() => selectedDailyGoal = goal.$5),
              ),
            )),
        SizedBox(height: 16.h),
        _codeExample('''
DailyGoalTile(
  time: '15',
  title: '15 phút/ngày',
  difficulty: 'Nghiêm túc',
  difficultyColor: AppColors.fox,
  isSelected: true,
  onTap: () {},
)
        '''),
      ],
    );
  }

  // ====================
  // HELPER: CODE EXAMPLE DISPLAY
  // ====================
  Widget _codeExample(String code) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.eel.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.swan),
      ),
      child: Text(
        code.trim(),
        style: TextStyle(
          fontSize: 11.sp,
          fontFamily: 'monospace',
          color: AppColors.eel,
          height: 1.5,
        ),
      ),
    );
  }
}
