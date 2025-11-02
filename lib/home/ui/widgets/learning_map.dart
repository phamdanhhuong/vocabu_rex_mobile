import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/tokens.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/header_section.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_level_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/user_progress_entity.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/node.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/node_types.dart';

/// Màn hình chính hiển thị bản đồ học tập (learning map).
/// Sử dụng CustomScrollView để có header dính (sticky header)
/// và danh sách các node bài học.
class LearningMapView extends StatelessWidget {
  final SkillEntity skillEntity;
  final UserProgressEntity userProgressEntity;

  const LearningMapView({
    super.key,
    required this.skillEntity,
    required this.userProgressEntity,
  });

  /// Hàm Helper để chuyển đổi logic
  /// (ví dụ: levelReached = 3, lessonPosition = 2)
  /// sang NodeStatus mà LessonNode yêu cầu.
  NodeStatus _getNodeStatus(
    int nodeIndex,
    UserProgressEntity progress,
    SkillLevelEntity level,
  ) {
    // Giả sử levelReached là 1-based (ví dụ: 1, 2, 3...)
    final int currentLevelIndex = progress.levelReached - 1;

    if (nodeIndex > currentLevelIndex) return NodeStatus.locked;
    if (nodeIndex < currentLevelIndex) return NodeStatus.completed;

    if (progress.lessonPosition >= (level.lessons?.length ?? 0)) return NodeStatus.completed;

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
  final Color? sectionShadowColor = (skillEntity.position >= 0 && shadowPalette.isNotEmpty)
      ? shadowPalette[skillEntity.position % shadowPalette.length]
      : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // 1. Thanh Header màu xanh lá
          SliverPersistentHeader(
            delegate: SectionHeaderDelegate(
              // TODO: Thay thế bằng dữ liệu thật
              title: 'PHẦN 1, CỬA 1',
              subtitle: 'Mời khách xơi nước',
              onPressed: () {},
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

              return Container(
                padding: const EdgeInsets.symmetric(vertical: AppTokens.nodeVerticalPadding, horizontal: AppTokens.nodeHorizontalPadding),
                alignment: Alignment(alignment, 0.0),
                child: LessonNode(
                  skillLevel: level,
                  status: status,
                  sectionColor: sectionColor,
                  sectionShadowColor: sectionShadowColor,
                  lessonPosition: (status == NodeStatus.inProgress) ? userProgressEntity.lessonPosition : 0,
                  totalLessons: level.lessons?.length ?? 0,
                ),
              );
            }, childCount: skillEntity.levels!.length),
          ),
        ],
      ),
    );
  }
}