import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_level_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/user_progress_entity.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/node.dart';

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

    if (nodeIndex > currentLevelIndex) {
      // 1. Node này nằm sau level hiện tại -> KHÓA
      return NodeStatus.locked;
    }
    
    if (nodeIndex < currentLevelIndex) {
      // 2. Node này nằm trước level hiện tại -> ĐÃ HOÀN THÀNH
      
      // TODO: Thêm logic kiểm tra huyền thoại
      // if (level.isLegendary) {
      //   return NodeStatus.legendary;
      // }
      return NodeStatus.completed;
    }

    // 3. Node này chính là level hiện tại
    if (progress.lessonPosition >= (level.lessons?.length ?? 0)) {
       // Đã học hết bài học của level này, nhưng chưa sang level mới
       // (Ví dụ: đang ở bài nâng cấp / level up)
       // Hiển thị là "completed" để người dùng có thể ôn tập hoặc nâng cấp
       return NodeStatus.completed;
    }
    
    // Vẫn đang học dở bài -> ĐANG LÀM
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // 1. Thanh Header màu xanh lá
          SliverPersistentHeader(
            delegate: _SectionHeaderDelegate(
              // TODO: Thay thế bằng dữ liệu thật
              title: 'PHẦN 1, CỬA 1',
              subtitle: 'Mời khách xơi nước',
              onPressed: () {
                // TODO: Xử lý nhấn nút menu
              },
            ),
            pinned: true, // Dính ở trên cùng
          ),

          // 2. Danh sách các Node bài học
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final level = skillEntity.levels![index];
                
                // --- SỬ DỤNG LOGIC MỚI ---
                final status = _getNodeStatus(index, userProgressEntity, level);
                
                // Tính toán vị trí (chẵn lệch trái, lẻ lệch phải)
                // -0.5 = Trái, 0.0 = Giữa, 0.5 = Phải
                final double alignment = (index % 2 == 0) ? -0.4 : 0.4;
                // TODO: Thêm logic cho các node đặc biệt (Rương, Mascot) ở alignment 0.0

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                  // Căn lề node sang trái/phải
                  alignment: Alignment(alignment, 0.0),
                  child: LessonNode(
                    skillLevel: level,
                    status: status,
                    lessonPosition: (status == NodeStatus.inProgress)
                        ? userProgressEntity.lessonPosition
                        : 0,
                    totalLessons: level.lessons?.length ?? 0,
                  ),
                );
              },
              childCount: skillEntity.levels!.length,
            ),
          ),
        ],
      ),
    );
  }
}

/// Delegate cho thanh Header màu xanh lá dính ở trên
class _SectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  _SectionHeaderDelegate({
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: const BoxDecoration(
        color: AppColors.primary, // Màu xanh lá
        border: Border(bottom: BorderSide(color: AppColors.wingOverlay, width: 2.0)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.onPrimary,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.onPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Nút Menu (Placeholder)
            IconButton(
              icon: const Icon(Icons.list, color: AppColors.onPrimary, size: 30),
              onPressed: onPressed,
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 110.0; // Chiều cao tối đa

  @override
  double get minExtent => 80.0; // Chiều cao tối thiểu (khi cuộn)

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

