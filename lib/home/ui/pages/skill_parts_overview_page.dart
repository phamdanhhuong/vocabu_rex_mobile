import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_part_entity.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/home_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/typography.dart';
import 'package:vocabu_rex_mobile/theme/tokens.dart';
import 'package:vocabu_rex_mobile/theme/widgets/speech_bubbles/speech_bubble.dart';
import 'package:vocabu_rex_mobile/theme/widgets/pressables/pressables.dart';

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
      backgroundColor: AppColors.background, // Hoặc màu trắng
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
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: skillParts.length,
        separatorBuilder: (context, index) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   'Chọn phần bạn muốn học',
                //   style: ... (Code cũ của bạn)
                // ),
                // const SizedBox(height: 16),
                _buildSkillPartCard(context, skillParts[index]),
              ],
            );
          }
          return _buildSkillPartCard(context, skillParts[index]);
        },
      ),
    );
  }

  Widget _buildSkillPartCard(BuildContext context, SkillPartEntity skillPart) {
    return _SkillPartCardStateful(
      skillPart: skillPart,
      currentSkillId: currentSkillId,
    );
  }
}

class _SkillPartCardStateful extends StatefulWidget {
  final SkillPartEntity skillPart;
  final String currentSkillId;

  const _SkillPartCardStateful({
    required this.skillPart,
    required this.currentSkillId,
  });

  @override
  State<_SkillPartCardStateful> createState() => _SkillPartCardStatefulState();
}

class _SkillPartCardStatefulState extends State<_SkillPartCardStateful> {
  bool _pressed = false;
  static const Duration _pressDuration = Duration(milliseconds: 90);

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    // Check logic
    final isCurrentPart =
        widget.skillPart.skills?.any((skill) => skill.id == widget.currentSkillId) ?? false;
    
    // Logic xác định trạng thái
    final bool isCompleted = widget.skillPart.progressPercentage == 100;
    final bool isActive = isCurrentPart; // Part đang học
    final bool canJumpAhead = !isActive && !isCompleted; // Tất cả parts chưa hoàn thành đều có thể học vượt
    
    // Màu nền header - tất cả đều unlocked
    final Color headerColor = isCompleted 
        ? AppColors.macawLight.withOpacity(0.5) // Part đã hoàn thành - màu nhạt hơn
        : AppColors.macawLight; // Màu xanh nhạt từ theme

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: () {
        // Handle navigation to skill part
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: _pressDuration,
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _pressed ? 3.0 : 0.0, 0),
        decoration: BoxDecoration(
          color: AppColors.snow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.swan,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _pressed ? Colors.transparent : AppColors.swan,
              offset: _pressed ? const Offset(0, 0) : const Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            // --- PHẦN HEADER (Màu xanh, chứa chat + nhân vật) ---
            Container(
              color: headerColor, 
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              height: 140, // Chiều cao cố định cho phần header để căn chỉnh nhân vật
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end, // Căn đáy để nhân vật đứng trên line
                children: [
                  // Cột chứa Bong bóng chat
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0, right: 8.0),
                      child: SpeechBubble(
                        variant: SpeechBubbleVariant.neutral,
                        tailDirection: SpeechBubbleTailDirection.right,
                        tailOffset: 60,
                        child: Text(
                          widget.skillPart.description ?? "Let's learn!",
                          style: AppTypography.defaultTextTheme(AppColors.bodyText)
                              .bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.bodyText,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  // Nhân vật (Owl)
                  _buildCharacterImage(isCompleted),
                ],
              ),
            ),

            // Divider giữa header và body
            Container(
              height: 2,
              color: AppColors.swan,
            ),

            // --- PHẦN BODY (Màu trắng, thông tin tiến độ) ---
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phần ${widget.skillPart.position}',
                    style: AppTypography.defaultTextTheme(AppColors.bodyText)
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w800, // Bold đậm
                          fontSize: 18,
                          color: AppColors.bodyText,
                        ),
                  ),
                  
                  const SizedBox(height: 12),

                  // Thanh tiến độ + Icon Cup
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 16, // Thanh to hơn giống hình
                          decoration: BoxDecoration(
                            color: AppColors.swan,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: (widget.skillPart.progressPercentage / 100).clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary, // Màu xanh lá
                                borderRadius: BorderRadius.circular(12),
                              ),
                              // Thêm highlight nhẹ trên thanh bar cho đẹp (optional)
                              child: Container(
                                margin: const EdgeInsets.only(top: 2, left: 4, right: 4, bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Icon Cup hoặc Huy hiệu
                      Icon(
                        Icons.emoji_events_rounded, // Hoặc Image asset cái cúp
                        color: isCompleted ? Colors.amber : AppColors.swan,
                        size: 32,
                      ),
                    ],
                  ),
                  
                  // Nút action buttons
                  if (canJumpAhead) ...[
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        // Load this skill part
                        if (widget.skillPart.skills != null && widget.skillPart.skills!.isNotEmpty) {
                          context.read<HomeBloc>().add(
                            LoadSkillPartEvent(skillPartId: widget.skillPart.id),
                          );
                          Navigator.of(context).pop(); // Close overview
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.macaw.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.macaw,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.rocket_launch_rounded,
                              color: AppColors.macaw,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'HỌC VƯỢT',
                              style: AppTypography.defaultTextTheme(AppColors.macaw)
                                  .labelLarge
                                  ?.copyWith(
                                    color: AppColors.macaw,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else if (isActive && !isCompleted) ...[
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        // Just close - user is already on this part
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'TIẾP TỤC HỌC',
                        style: AppTypography.defaultTextTheme(AppColors.primary)
                            .labelLarge
                            ?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                      ),
                    ),
                  ] else if (isCompleted) ...[
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        // Load this part for review
                        if (widget.skillPart.skills != null && widget.skillPart.skills!.isNotEmpty) {
                          context.read<HomeBloc>().add(
                            LoadSkillPartEvent(skillPartId: widget.skillPart.id),
                          );
                          Navigator.of(context).pop();
                        }
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ĐÃ HOÀN THÀNH - ÔN TẬP',
                            style: AppTypography.defaultTextTheme(AppColors.primary)
                                .labelLarge
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget vẽ nhân vật - sử dụng ảnh từ assets
  Widget _buildCharacterImage(bool isCompleted) {
    // Kích thước nhân vật
    const double size = 90;

    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.only(bottom: 0), // Sát đáy container màu xanh
      alignment: Alignment.bottomCenter,
      child: Image.asset(
        'assets/logo.png', // Thay đổi path này nếu có asset nhân vật khác
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback nếu không tìm thấy ảnh
          return Icon(
            Icons.person,
            size: size,
            color: isCompleted ? Colors.amber : AppColors.primary,
          );
        },
      ),
    );
  }
}