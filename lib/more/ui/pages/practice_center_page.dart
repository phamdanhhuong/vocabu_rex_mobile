import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/exercise/data/services/exercise_service.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/action_card_button.dart';

class PracticeCenterPage extends StatelessWidget {
  const PracticeCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.snow,
      appBar: AppBar(
        backgroundColor: AppColors.featherGreen,
        foregroundColor: AppColors.snow,
        elevation: 0,
        title: Text(
          'Practice Center',
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.snow,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Master Your Skills',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.wolf,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Practice different aspects of language learning',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.eel),
            ),
            SizedBox(height: 16.h),

            // Review Card (Tập trung khắc phục điểm yếu)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF58CC02), Color(0xFF89E219)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.featherGreen.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.track_changes,
                          color: Colors.white,
                          size: 28.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Khắc phục điểm yếu',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Luyện tập các bài bạn thường làm sai',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Future.microtask(() {
                          Navigator.pushNamed(
                            context,
                            '/exercise',
                            arguments: {
                              'lessonId': 'training',
                              'lessonTitle': 'Luyện tập',
                              'isPronun': false,
                            },
                          );
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.featherGreen,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'BẮT ĐẦU',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // ── AI Practice Card ──
            _AiPracticeCard(),
            SizedBox(height: 24.h),

            // Practice categories
            ActionCardButton(
              icon: Icons.menu_book,
              iconColor: AppColors.featherGreen,
              iconBackgroundColor: AppColors.featherGreen.withOpacity(0.15),
              text: 'Vocabulary',
              onTap: () =>
                  _navigateToTraining(context, 'vocabulary', 'Vocabulary'),
            ),
            SizedBox(height: 16.h),

            ActionCardButton(
              icon: Icons.psychology,
              iconColor: AppColors.macaw,
              iconBackgroundColor: AppColors.macaw.withOpacity(0.15),
              text: 'Grammar',
              onTap: () => _navigateToTraining(context, 'grammar', 'Grammar'),
            ),
            SizedBox(height: 16.h),

            ActionCardButton(
              icon: Icons.hearing,
              iconColor: const Color(0xFFFF9500),
              iconBackgroundColor: const Color(0xFFFF9500).withOpacity(0.15),
              text: 'Listening',
              onTap: () => _navigateToTraining(context, 'listen', 'Listening'),
            ),
            SizedBox(height: 16.h),

            ActionCardButton(
              icon: Icons.record_voice_over,
              iconColor: const Color(0xFFFF3B30),
              iconBackgroundColor: const Color(0xFFFF3B30).withOpacity(0.15),
              text: 'Speaking',
              onTap: () => _navigateToTraining(context, 'speak', 'Speaking'),
            ),
            SizedBox(height: 16.h),

            ActionCardButton(
              icon: Icons.edit_note,
              iconColor: const Color(0xFF5856D6),
              iconBackgroundColor: const Color(0xFF5856D6).withOpacity(0.15),
              text: 'Writing',
              onTap: () => _navigateToTraining(context, 'writing', 'Writing'),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  void _navigateToTraining(
    BuildContext context,
    String trainingType,
    String title,
  ) {
    Future.microtask(() {
      Navigator.pushNamed(
        context,
        '/exercise',
        arguments: {
          'lessonId': 'training-$trainingType',
          'lessonTitle': title,
          'isPronun': false,
        },
      );
    });
  }
}

// ── AI Practice Card Widget ──

class _AiPracticeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Luyện tập với AI',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Bài tập được tạo bởi AI theo chủ đề bạn chọn',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showGenerateSheet(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF7C3AED),
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'TẠO BÀI TẬP',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGenerateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _GenerateExerciseSheet(),
    );
  }
}

// ── Bottom Sheet for AI Exercise Generation ──

class _GenerateExerciseSheet extends StatefulWidget {
  const _GenerateExerciseSheet();

  @override
  State<_GenerateExerciseSheet> createState() => _GenerateExerciseSheetState();
}

class _GenerateExerciseSheetState extends State<_GenerateExerciseSheet> {
  String? _selectedTopic;
  String _selectedDifficulty = 'intermediate';
  bool _isLoading = false;
  String? _errorMessage;

  static const List<String> _topics = [
    'Daily Life & Routines',
    'Travel & Tourism',
    'Food & Cooking',
    'Health & Fitness',
    'Technology & Internet',
    'Education & Learning',
    'Work & Career',
    'Environment & Nature',
    'Entertainment & Media',
    'Shopping & Fashion',
    'Family & Relationships',
    'Sports & Hobbies',
    'Culture & Traditions',
    'Science & Discovery',
    'City & Transportation',
  ];

  static const Map<String, String> _difficulties = {
    'beginner': 'Beginner',
    'elementary': 'Elementary',
    'intermediate': 'Intermediate',
    'upper_intermediate': 'Upper Intermediate',
    'advanced': 'Advanced',
  };

  Future<void> _generate() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ExerciseService().generateAiExercises(
        topic: _selectedTopic,
        difficulty: _selectedDifficulty,
        exerciseCount: 5,
      );

      if (!mounted) return;

      final lessonId = result['lessonId'] as String;
      final lessonTitle = result['lessonTitle'] as String;

      // Close bottom sheet
      Navigator.pop(context);

      // Navigate to exercise page
      Future.microtask(() {
        Navigator.pushNamed(
          context,
          '/exercise',
          arguments: {
            'lessonId': lessonId,
            'lessonTitle': lessonTitle,
            'isPronun': false,
          },
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Không thể tạo bài tập. Vui lòng thử lại.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Title
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: const Color(0xFF7C3AED),
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Tạo bài tập AI',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.wolf,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'Chọn chủ đề và độ khó để AI tạo bài tập cho bạn',
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.eel),
            ),
            SizedBox(height: 24.h),

            // Topic Dropdown
            Text(
              'Chủ đề',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.wolf,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12.r),
                color: Colors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: _selectedTopic,
                  isExpanded: true,
                  hint: Text(
                    '🎲  Ngẫu nhiên',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  icon: Icon(Icons.keyboard_arrow_down, size: 24.sp),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(
                        '🎲  Ngẫu nhiên',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                    ..._topics.map(
                      (topic) => DropdownMenuItem(
                        value: topic,
                        child: Text(topic, style: TextStyle(fontSize: 14.sp)),
                      ),
                    ),
                  ],
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          setState(() => _selectedTopic = value);
                        },
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Difficulty Dropdown
            Text(
              'Độ khó',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.wolf,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12.r),
                color: Colors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedDifficulty,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down, size: 24.sp),
                  items: _difficulties.entries
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(
                            e.value,
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _selectedDifficulty = value);
                          }
                        },
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Error message
            if (_errorMessage != null) ...[
              Container(
                padding: EdgeInsets.all(12.h),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 20.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red, fontSize: 13.sp),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
            ],

            // Generate button
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(
                    0xFF7C3AED,
                  ).withOpacity(0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20.sp,
                            height: 20.sp,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'Đang tạo bài tập...',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.sp,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'TẠO BÀI TẬP',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.sp,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
