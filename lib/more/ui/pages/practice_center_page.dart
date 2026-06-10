import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/exercise/data/services/exercise_service.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/action_card_button.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import 'package:vocabu_rex_mobile/web/widgets/web_page_wrapper.dart';

class PracticeCenterPage extends StatelessWidget {
  const PracticeCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: AppPreferences(),
      builder: (context, _) {
        return WebPageWrapper(
          mobileScaffold: Scaffold(
            backgroundColor: AppColors.snow,
            appBar: AppBar(
              backgroundColor: AppColors.snow,
              foregroundColor: AppColors.bodyText,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Text(
                'Trung tâm luyện tập',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.bodyText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Phát triển kỹ năng',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.wolf,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Luyện tập các khía cạnh khác nhau của ngôn ngữ',
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.eel),
                  ),
                  SizedBox(height: 24.h),

                  // ── Review & AI Practice Cards Row ──
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
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
                          borderRadius: BorderRadius.circular(16.r),
                          child: Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: AppPreferences().isDarkMode 
                                    ? [AppColors.primary.withOpacity(0.5), AppColors.correctGreenDark]
                                    : [const Color(0xFF58CC02), const Color(0xFF89E219)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.hare.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.w),
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
                                SizedBox(height: 12.h),
                                Text(
                                  'Điểm yếu',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.sp,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Ôn lỗi sai',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 12.sp,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: const _AiPracticeCard(),
                      ),
                    ],
                  ),
                  ),
                  SizedBox(height: 24.h),

                  Text(
                    'Khám phá',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.wolf,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Practice categories
                  ActionCardButton(
                    icon: Icons.menu_book,
                    iconColor: AppPreferences().isDarkMode ? AppColors.featherGreen : const Color(0xFF58CC02),
                    iconBackgroundColor: AppPreferences().isDarkMode ? AppColors.featherGreen.withOpacity(0.2) : const Color(0xFF58CC02).withOpacity(0.15),
                    text: 'Từ vựng (Vocabulary)',
                    onTap: () =>
                        _navigateToTraining(context, 'vocabulary', 'Từ vựng'),
                  ),
                  SizedBox(height: 12.h),

                  ActionCardButton(
                    icon: Icons.psychology,
                    iconColor: AppPreferences().isDarkMode ? AppColors.macaw : const Color(0xFF1CB0F6),
                    iconBackgroundColor: AppPreferences().isDarkMode ? AppColors.macaw.withOpacity(0.2) : const Color(0xFF1CB0F6).withOpacity(0.15),
                    text: 'Ngữ pháp (Grammar)',
                    onTap: () => _navigateToTraining(context, 'grammar', 'Ngữ pháp'),
                  ),
                  SizedBox(height: 12.h),

                  ActionCardButton(
                    icon: Icons.hearing,
                    iconColor: AppPreferences().isDarkMode ? AppColors.fox : const Color(0xFFFF9500),
                    iconBackgroundColor: AppPreferences().isDarkMode ? AppColors.fox.withOpacity(0.2) : const Color(0xFFFF9500).withOpacity(0.15),
                    text: 'Luyện nghe (Listening)',
                    onTap: () => _navigateToTraining(context, 'listen', 'Luyện nghe'),
                  ),
                  SizedBox(height: 12.h),

                  ActionCardButton(
                    icon: Icons.record_voice_over,
                    iconColor: AppPreferences().isDarkMode ? AppColors.cardinal : const Color(0xFFFF3B30),
                    iconBackgroundColor: AppPreferences().isDarkMode ? AppColors.cardinal.withOpacity(0.2) : const Color(0xFFFF3B30).withOpacity(0.15),
                    text: 'Luyện nói (Speaking)',
                    onTap: () => _navigateToTraining(context, 'speak', 'Luyện nói'),
                  ),
                  SizedBox(height: 12.h),

                  ActionCardButton(
                    icon: Icons.edit_note,
                    iconColor: AppPreferences().isDarkMode ? const Color(0xFF9E7BFF) : const Color(0xFF5856D6),
                    iconBackgroundColor: AppPreferences().isDarkMode ? const Color(0xFF9E7BFF).withOpacity(0.2) : const Color(0xFF5856D6).withOpacity(0.15),
                    text: 'Luyện viết (Writing)',
                    onTap: () => _navigateToTraining(context, 'writing', 'Luyện viết'),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        );
      },
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
  const _AiPracticeCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _showGenerateSheet(context),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppPreferences().isDarkMode 
                ? [const Color(0xFF5B21B6), const Color(0xFF7E22CE)]
                : [const Color(0xFF7C3AED), const Color(0xFFA855F7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.hare.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
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
            SizedBox(height: 12.h),
            Text(
              'Với AI',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            Text(
              'Tạo bài tự động',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.85),
                fontSize: 12.sp,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
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

    return ListenableBuilder(
      listenable: AppPreferences(),
      builder: (context, _) {
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
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: AppColors.swan,
                      borderRadius: BorderRadius.circular(2.5.r),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Title
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: AppPreferences().isDarkMode ? const Color(0xFFA855F7) : const Color(0xFF7C3AED),
                      size: 24.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Tạo bài tập AI',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.bodyText,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  'Chọn chủ đề và độ khó để AI tạo bài tập cho bạn',
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.wolf),
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
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.swan, width: 2),
                    borderRadius: BorderRadius.circular(16.r),
                    color: AppColors.polar,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _selectedTopic,
                      isExpanded: true,
                      dropdownColor: AppColors.snow,
                      hint: Text(
                        '🎲  Ngẫu nhiên',
                        style: TextStyle(fontSize: 16.sp, color: AppColors.bodyText),
                      ),
                      icon: Icon(Icons.keyboard_arrow_down, size: 24.sp, color: AppColors.bodyText),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(
                            '🎲  Ngẫu nhiên',
                            style: TextStyle(fontSize: 16.sp, color: AppColors.bodyText),
                          ),
                        ),
                        ..._topics.map(
                          (topic) => DropdownMenuItem(
                            value: topic,
                            child: Text(topic, style: TextStyle(fontSize: 16.sp, color: AppColors.bodyText)),
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
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.swan, width: 2),
                    borderRadius: BorderRadius.circular(16.r),
                    color: AppColors.polar,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedDifficulty,
                      isExpanded: true,
                      dropdownColor: AppColors.snow,
                      icon: Icon(Icons.keyboard_arrow_down, size: 24.sp, color: AppColors.bodyText),
                      items: _difficulties.entries
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(
                                e.value,
                                style: TextStyle(fontSize: 16.sp, color: AppColors.bodyText),
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
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppPreferences().isDarkMode ? AppColors.incorrectRedDark : AppColors.incorrectRedLight,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: AppColors.cardinal, size: 20.sp),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: AppColors.cardinal, fontSize: 13.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],

                // Generate button
                AppButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, size: 20.sp, color: AppColors.snow),
                      SizedBox(width: 8.w),
                      Text(
                        'TẠO BÀI TẬP',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                          color: AppColors.snow,
                        ),
                      ),
                    ],
                  ),
                  onPressed: _generate,
                  isLoading: _isLoading,
                  variant: ButtonVariant.primary,
                  width: double.infinity,
                  size: ButtonSize.large,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
