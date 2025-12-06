import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/show_case_cubit.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/tokens.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/header_section.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_level_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_part_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/user_progress_entity.dart';
import 'package:vocabu_rex_mobile/home/ui/pages/grammar_guide_page.dart';
import 'package:vocabu_rex_mobile/home/ui/pages/skill_parts_overview_page.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/node.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/node_types.dart';

/// Màn hình chính hiển thị bản đồ học tập (learning map).
/// Sử dụng CustomScrollView để có header dính (sticky header)
/// và danh sách các node bài học.
class LearningMapView extends StatelessWidget {
  final SkillEntity skillEntity;
  final UserProgressEntity userProgressEntity;
  final SkillPartEntity? skillPartEntity;
  final List<SkillPartEntity>? allSkillParts;

  const LearningMapView({
    super.key,
    required this.skillEntity,
    required this.userProgressEntity,
    this.skillPartEntity,
    this.allSkillParts,
  });

  /// Hàm Helper để chuyển đổi logic
  /// (ví dụ: levelReached = 3, lessonPosition = 2)
  /// sang NodeStatus mà LessonNode yêu cầu.
  ///
  /// Logic:
  /// - levelReached là level hiện tại của user (1-based)
  /// - Các level trước levelReached → completed
  /// - Level tại levelReached → inProgress (kể cả khi đã hoàn thành hết các bài)
  /// - Các level sau levelReached → locked
  NodeStatus _getNodeStatus(
    int nodeIndex,
    UserProgressEntity progress,
    SkillLevelEntity level,
  ) {
    // levelReached là 1-based (ví dụ: 1, 2, 3...)
    // nodeIndex là 0-based (0, 1, 2...)
    final int currentLevelIndex = progress.levelReached - 1;

    // Các level sau level hiện tại → locked
    if (nodeIndex > currentLevelIndex) return NodeStatus.locked;

    // Các level trước level hiện tại → completed
    if (nodeIndex < currentLevelIndex) return NodeStatus.completed;

    // Level hiện tại → luôn là inProgress
    // (kể cả khi lessonPosition = totalLessons)
    return NodeStatus.inProgress;
  }

  @override
  Widget build(BuildContext context) {
    if (skillEntity.levels == null || skillEntity.levels!.isEmpty) {
      return const Center(
        child: Text(
          'No levels available',
          style: TextStyle(color: AppColors.bodyText),
        ),
      );
    }

    // Determine section colors by skill position using lessonHeaderPalette (fallback to primary)
    final palette = AppColors.lessonHeaderPalette;
    final Color sectionColor = (skillEntity.position >= 0 && palette.isNotEmpty)
        ? palette[skillEntity.position % palette.length]
        : AppColors.primary;
    // Determine per-section shadow color using the shadow palette
    final shadowPalette = AppColors.lessonHeaderShadowPalette;
    final Color? sectionShadowColor =
        (skillEntity.position >= 0 && shadowPalette.isNotEmpty)
        ? shadowPalette[skillEntity.position % shadowPalette.length]
        : null;

    final GlobalKey nodeKey = GlobalKey();
    context.read<ShowCaseCubit>().registerKey('node', nodeKey);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // 1. Thanh Header màu xanh lá
          SliverPersistentHeader(
            delegate: SectionHeaderDelegate(
              title:
                  'PHẦN ${skillPartEntity?.position ?? 1}, CỬA ${skillEntity.position}',
              subtitle: skillEntity.title,
              onPressed: () {
                if (allSkillParts != null && allSkillParts!.isNotEmpty) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SkillPartsOverviewPage(
                        skillParts: allSkillParts!,
                        currentSkillId: skillEntity.id,
                      ),
                    ),
                  );
                }
              },
              onListPressed: () {
                // Find the skill with grammars from skillPartEntity
                SkillEntity? skillWithGrammars;
                if (skillPartEntity?.skills != null) {
                  try {
                    skillWithGrammars = skillPartEntity!.skills!.firstWhere(
                      (skill) => skill.id == skillEntity.id,
                    );
                  } catch (e) {
                    // If not found, use skillEntity as fallback
                    skillWithGrammars = skillEntity;
                  }
                } else {
                  skillWithGrammars = skillEntity;
                }

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => GrammarGuidePage(
                      skillEntity: skillWithGrammars ?? skillEntity,
                      skillTitle: skillEntity.title,
                      partPosition: skillPartEntity?.position,
                    ),
                  ),
                );
              },
              buttonColor: sectionColor,
              shadowColor: sectionShadowColor,
            ),
            pinned: true,
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final level = skillEntity.levels![index];
              final status = _getNodeStatus(index, userProgressEntity, level);

              // Wave alignment starting from center: [0, -a, 0, a, ...]
              final double amplitude = AppTokens.nodeWaveAmplitude;
              final int wavePhase = index % 4;
              final double alignment = (wavePhase == 1)
                  ? -amplitude
                  : (wavePhase == 3)
                  ? amplitude
                  : 0.0;

              final node = LessonNode(
                skillLevel: level,
                status: status,
                sectionColor: sectionColor,
                sectionShadowColor: sectionShadowColor,
                lessonPosition: (status == NodeStatus.inProgress)
                    ? userProgressEntity.lessonPosition
                    : 0,
                totalLessons: level.lessons?.length ?? 0,
              );

              if (level.level == 1) {
                final nodeShowCase = Showcase(
                  key: nodeKey,
                  description: "Bấm vào đây để xem bài học",
                  disableDefaultTargetGestures: true,
                  onTargetClick: () {
                    ShowCaseWidget.of(context).next();
                  },
                  disposeOnTap: true,
                  child: node,
                );
                return Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTokens.nodeVerticalPadding,
                    horizontal: AppTokens.nodeHorizontalPadding,
                  ),
                  alignment: Alignment(alignment, 0.0),
                  child: nodeShowCase,
                );
              }

              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppTokens.nodeVerticalPadding,
                  horizontal: AppTokens.nodeHorizontalPadding,
                ),
                alignment: Alignment(alignment, 0.0),
                child: node,
              );
            }, childCount: skillEntity.levels!.length),
          ),
        ],
      ),
    );
  }
}
