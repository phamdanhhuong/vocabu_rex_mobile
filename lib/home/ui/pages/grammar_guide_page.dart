import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/grammar_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_entity.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/typography.dart';

class GrammarGuidePage extends StatelessWidget {
  final SkillEntity skillEntity;
  final String skillTitle;

  const GrammarGuidePage({
    super.key,
    required this.skillEntity,
    required this.skillTitle,
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
        title: Column(
          children: [
            Text(
              skillTitle,
              style: AppTypography.defaultTextTheme(AppColors.bodyText)
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.bodyText,
                  ),
            ),
            Text(
              'Học các chủ điểm ngữ pháp và xem các cụm từ chính của cửa này',
              style: AppTypography.defaultTextTheme(AppColors.bodyText)
                  .bodySmall
                  ?.copyWith(
                    color: AppColors.bodyText.withOpacity(0.7),
                    fontSize: 12,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: skillEntity.grammars == null || skillEntity.grammars!.isEmpty
          ? const Center(
              child: Text(
                'Không có ngữ pháp nào cho skill này',
                style: TextStyle(color: AppColors.bodyText, fontSize: 16),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'CỤM TỪ CHÍNH',
                              style:
                                  AppTypography.defaultTextTheme(
                                    AppColors.primary,
                                  ).labelMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                    letterSpacing: 0.5,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Đưa ra lời khuyên cải thiện bản thân',
                          style:
                              AppTypography.defaultTextTheme(
                                AppColors.bodyText,
                              ).titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.bodyText,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...skillEntity.grammars!.map(
                    (grammar) => _buildGrammarCard(grammar),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildGrammarCard(GrammarEntity grammar) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.polar,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.swan),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            grammar.rule,
            style: AppTypography.defaultTextTheme(AppColors.bodyText)
                .titleMedium
                ?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.bodyText,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            grammar.explanation,
            style: AppTypography.defaultTextTheme(AppColors.bodyText).bodyMedium
                ?.copyWith(
                  color: AppColors.bodyText.withOpacity(0.8),
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 16),
          ...grammar.examples.map((example) => _buildExampleItem(example)),
        ],
      ),
    );
  }

  Widget _buildExampleItem(String example) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, right: 12),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      example,
                      style: AppTypography.defaultTextTheme(AppColors.bodyText)
                          .bodyMedium
                          ?.copyWith(
                            color: AppColors.bodyText,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // TODO: Add text-to-speech functionality
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.volume_up,
                        size: 16,
                        color: AppColors.primary,
                      ),
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
}
