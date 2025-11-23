import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_part_entity.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/typography.dart';

class SkillPartsOverviewPage extends StatelessWidget {
  final List<SkillPartEntity> skillParts;
  final String currentSkillId;

  const SkillPartsOverviewPage({
    super.key,
    required this.skillParts,
    required this.currentSkillId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.bodyText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Các phần học',
          style: AppTypography.defaultTextTheme(AppColors.bodyText).titleLarge
              ?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.bodyText,
              ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn phần bạn muốn học',
              style: AppTypography.defaultTextTheme(AppColors.bodyText)
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.bodyText,
                  ),
            ),
            const SizedBox(height: 16),
            ...skillParts.map(
              (skillPart) => _buildSkillPartCard(context, skillPart),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillPartCard(BuildContext context, SkillPartEntity skillPart) {
    // Check if this skill part contains current skill
    final isCurrentPart =
        skillPart.skills?.any((skill) => skill.id == currentSkillId) ?? false;

    // Determine status based on progress
    String status;
    Color statusColor;
    if (skillPart.progressPercentage == 100) {
      status = 'HOÀN THÀNH';
      statusColor = AppColors.primary;
    } else if (skillPart.progressPercentage > 0 || isCurrentPart) {
      status = 'HỌC VƯỢT';
      statusColor = AppColors.macaw;
    } else {
      status = 'KHÓA';
      statusColor = AppColors.hare;
    }

    // Create different character expressions based on status
    Widget characterWidget;
    if (skillPart.progressPercentage == 100) {
      characterWidget = _buildCharacterWidget('😊', AppColors.primary);
    } else if (skillPart.progressPercentage > 0 || isCurrentPart) {
      characterWidget = _buildCharacterWidget('🤔', AppColors.macaw);
    } else {
      characterWidget = _buildCharacterWidget('😴', AppColors.hare);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentPart ? AppColors.primary : AppColors.swan,
          width: isCurrentPart ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to specific skill part or show message if locked
            if (skillPart.progressPercentage > 0 || isCurrentPart) {
              Navigator.of(context).pop(); // For now, just close
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Phần này chưa được mở khóa')),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Character and speech bubble
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Speech bubble
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.polar,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          skillPart.description ?? 'Mô tả phần học',
                          style:
                              AppTypography.defaultTextTheme(
                                AppColors.bodyText,
                              ).bodyMedium?.copyWith(
                                color: AppColors.bodyText,
                                height: 1.4,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Part title and progress
                      Text(
                        'Phần ${skillPart.position}',
                        style:
                            AppTypography.defaultTextTheme(
                              AppColors.bodyText,
                            ).titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.bodyText,
                            ),
                      ),
                      const SizedBox(height: 8),

                      // Progress bar
                      if (skillPart.progressPercentage > 0 || isCurrentPart)
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: AppColors.swan,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor:
                                          skillPart.progressPercentage / 100,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${skillPart.progressPercentage}%',
                                  style:
                                      AppTypography.defaultTextTheme(
                                        AppColors.hare,
                                      ).bodySmall?.copyWith(
                                        color: AppColors.hare,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),

                      // Status
                      Text(
                        status,
                        style: AppTypography.defaultTextTheme(statusColor)
                            .labelMedium
                            ?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                      ),
                    ],
                  ),
                ),

                // Character
                const SizedBox(width: 16),
                characterWidget,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterWidget(String emoji, Color color) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 40))),
    );
  }
}
