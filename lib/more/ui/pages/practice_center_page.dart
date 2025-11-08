import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

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
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.eel,
              ),
            ),
            SizedBox(height: 24.h),

            // Practice categories
            _buildPracticeCard(
              context: context,
              icon: Icons.menu_book,
              title: 'Vocabulary',
              description: 'Learn and review new words',
              color: AppColors.featherGreen,
              progress: 0.65,
              exercises: 45,
            ),
            SizedBox(height: 16.h),

            _buildPracticeCard(
              context: context,
              icon: Icons.psychology,
              title: 'Grammar',
              description: 'Master grammar rules and structures',
              color: AppColors.macaw,
              progress: 0.42,
              exercises: 32,
            ),
            SizedBox(height: 16.h),

            _buildPracticeCard(
              context: context,
              icon: Icons.hearing,
              title: 'Listening',
              description: 'Improve your listening comprehension',
              color: Color(0xFFFF9500),
              progress: 0.58,
              exercises: 28,
            ),
            SizedBox(height: 16.h),

            _buildPracticeCard(
              context: context,
              icon: Icons.record_voice_over,
              title: 'Speaking',
              description: 'Practice pronunciation and fluency',
              color: Color(0xFFFF3B30),
              progress: 0.35,
              exercises: 24,
            ),
            SizedBox(height: 16.h),

            _buildPracticeCard(
              context: context,
              icon: Icons.edit_note,
              title: 'Writing',
              description: 'Enhance your writing skills',
              color: Color(0xFF5856D6),
              progress: 0.28,
              exercises: 18,
            ),
            SizedBox(height: 16.h),

            _buildPracticeCard(
              context: context,
              icon: Icons.auto_stories,
              title: 'Reading',
              description: 'Improve reading speed and comprehension',
              color: Color(0xFF34C759),
              progress: 0.72,
              exercises: 36,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPracticeCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required double progress,
    required int exercises,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.wolf.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.wolf.withOpacity(0.08),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to specific practice section
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$title practice coming soon!'),
                backgroundColor: color,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon
                    Container(
                      width: 56.w,
                      height: 56.w,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 28.sp,
                      ),
                    ),
                    SizedBox(width: 16.h),

                    // Title and description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColors.wolf,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.eel,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Arrow
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.wolf.withOpacity(0.4),
                      size: 16.sp,
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.eel,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: color.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 8.h,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '$exercises exercises available',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.eel,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
