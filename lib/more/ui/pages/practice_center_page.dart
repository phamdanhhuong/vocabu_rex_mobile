import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

            // Practice categories
            ActionCardButton(
              icon: Icons.menu_book,
              iconColor: AppColors.featherGreen,
              iconBackgroundColor: AppColors.featherGreen.withOpacity(0.15),
              text: 'Vocabulary',
              onTap: () => _navigateToTraining(context, 'vocabulary', 'Vocabulary'),
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

  void _navigateToTraining(BuildContext context, String trainingType, String title) {
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
