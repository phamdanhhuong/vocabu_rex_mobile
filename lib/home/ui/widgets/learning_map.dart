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
                
                // Tính toán vị trí theo dạng lượn sóng bắt đầu từ giữa
                // Mẫu: [0, -a, 0, a, 0, -a, ...] giống Duolingo (bắt đầu ở giữa)
                // -0.5 = Trái, 0.0 = Giữa, 0.5 = Phải
                const double amplitude = 0.48; // điều chỉnh để tăng/giảm lệch
                final int wavePhase = index % 4;
                late final double alignment;
                switch (wavePhase) {
                  case 0:
                    alignment = 0.0; // giữa
                    break;
                  case 1:
                    alignment = -amplitude; // lệch trái
                    break;
                  case 2:
                    alignment = 0.0; // giữa
                    break;
                  case 3:
                  default:
                    alignment = amplitude; // lệch phải
                    break;
                }
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
    return SizedBox(
      height: maxExtent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              // Left expanded area becomes one rounded button
              Expanded(
                child: _PressableRounded(
                  onTap: onPressed,
                  height: 56,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            height: 1.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            height: 1.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Right icon button as a single rounded button
              _CircleIconButton(
                icon: Icons.list,
                onTap: onPressed,
                height: 56,
                width: 56,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
            ],
          ),
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

// Small pressable rounded surface that scales on press (mimics app_button)
class _PressableRounded extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double? height;
  final BorderRadius? borderRadius;

  const _PressableRounded({Key? key, required this.child, this.onTap, this.height, this.borderRadius}) : super(key: key);

  @override
  State<_PressableRounded> createState() => _PressableRoundedState();
}

class _PressableRoundedState extends State<_PressableRounded> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.98).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  void _onTapDown(TapDownDetails d) => _c.forward();
  void _onTapUp(TapUpDetails d) async { await _c.reverse(); widget.onTap?.call(); }
  void _onTapCancel() => _c.reverse();

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(scale: _scale.value, child: child),
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// Circular icon button with scale press animation
class _CircleIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;

  const _CircleIconButton({Key? key, required this.icon, this.onTap, this.height, this.width, this.borderRadius}) : super(key: key);

  @override
  State<_CircleIconButton> createState() => _CircleIconButtonState();
}

class _CircleIconButtonState extends State<_CircleIconButton> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  void _onTapDown(TapDownDetails d) => _c.forward();
  void _onTapUp(TapUpDetails d) async { await _c.reverse(); widget.onTap?.call(); }
  void _onTapCancel() => _c.reverse();

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(scale: _scale.value, child: child),
        child: Container(
          width: widget.width ?? 44,
          height: widget.height ?? 44,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(999),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
          ),
          child: Icon(widget.icon, color: AppColors.primary, size: 20),
        ),
      ),
    );
  }
}

