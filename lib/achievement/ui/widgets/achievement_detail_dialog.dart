import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/achievement/domain/entities/achievement_entity.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

/// Achievement detail dialog — modern Duolingo-inspired design
class AchievementDetailDialog extends StatelessWidget {
  final AchievementEntity achievement;

  const AchievementDetailDialog({super.key, required this.achievement});

  // Determine badge asset
  String getBadgeAsset() {
    return AchievementAssetHelper.resolveAssetPath(achievement);
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = !achievement.isUnlocked && achievement.progress == 0;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        decoration: BoxDecoration(
          color: AppColors.snow,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Colored header with badge
            _buildHeader(context, isLocked),

            // Content body
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                children: [
                  // Achievement name
                  Text(
                    achievement.achievement.name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.eel,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    achievement.achievement.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.wolf,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Status chip
                  _buildStatusChip(),
                  const SizedBox(height: 20),

                  // Progress section
                  _buildProgressSection(),
                  const SizedBox(height: 16),

                  // Rewards section
                  if (achievement.achievement.rewardXp > 0 ||
                      achievement.achievement.rewardGems > 0) ...[
                    _buildRewardsSection(),
                    const SizedBox(height: 16),
                  ],

                  // Tier + Category row
                  _buildInfoRow(),
                  const SizedBox(height: 20),

                  // Close button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: achievement.isUnlocked
                            ? AppColors.featherGreen
                            : AppColors.swan,
                        foregroundColor: achievement.isUnlocked
                            ? AppColors.white
                            : AppColors.eel,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Đóng',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header with gradient background + badge image
  // ---------------------------------------------------------------------------
  Widget _buildHeader(BuildContext context, bool isLocked) {
    final Color headerColor;
    final Color headerColorLight;

    if (achievement.isUnlocked) {
      headerColor = AppColors.featherGreen;
      headerColorLight = AppColors.maskGreen;
    } else if (achievement.isInProgress) {
      headerColor = AppColors.bee;
      headerColorLight = const Color(0xFFFFE066);
    } else {
      headerColor = AppColors.hare;
      headerColorLight = AppColors.swan;
    }

    const greyscaleMatrix = <double>[
      0.2126,
      0.7152,
      0.0722,
      0,
      0,
      0.2126,
      0.7152,
      0.0722,
      0,
      0,
      0.2126,
      0.7152,
      0.0722,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];

    final badgeAsset = getBadgeAsset();

    Widget badgeImage = Image.asset(
      badgeAsset,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          achievement.achievement.categoryIcon,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(
            Icons.emoji_events_rounded,
            size: 64,
            color: isLocked ? AppColors.hare : AppColors.bee,
          ),
        );
      },
    );

    Widget badge = isLocked
        ? ColorFiltered(
            colorFilter: const ColorFilter.matrix(greyscaleMatrix),
            child: Opacity(opacity: 0.45, child: badgeImage),
          )
        : badgeImage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            headerColor.withValues(alpha: 0.12),
            headerColorLight.withValues(alpha: 0.06),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow ring for unlocked
          if (achievement.isUnlocked)
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.featherGreen.withValues(alpha: 0.25),
                    blurRadius: 32,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),

          // Badge image
          SizedBox(height: 120, width: 120, child: badge),

          // Lock overlay
          if (isLocked)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Status chip (Đã mở khoá / Đang thực hiện / Chưa mở khoá)
  // ---------------------------------------------------------------------------
  Widget _buildStatusChip() {
    final Color chipColor;
    final Color chipBg;
    final IconData chipIcon;
    final String chipText;

    if (achievement.isUnlocked) {
      chipColor = AppColors.featherGreen;
      chipBg = AppColors.featherGreen.withValues(alpha: 0.1);
      chipIcon = Icons.check_circle_rounded;
      chipText = 'Đã mở khoá';
    } else if (achievement.isInProgress) {
      chipColor = const Color(0xFFE5A905);
      chipBg = AppColors.bee.withValues(alpha: 0.1);
      chipIcon = Icons.trending_up_rounded;
      chipText = 'Đang thực hiện';
    } else {
      chipColor = AppColors.hare;
      chipBg = AppColors.hare.withValues(alpha: 0.12);
      chipIcon = Icons.lock_rounded;
      chipText = 'Chưa mở khoá';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(chipIcon, size: 18, color: chipColor),
          const SizedBox(width: 6),
          Text(
            chipText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Progress bar section
  // ---------------------------------------------------------------------------
  Widget _buildProgressSection() {
    final requirement = achievement.achievement.requirement;
    final progress = achievement.progress;
    final percentage = achievement.progressPercentage;

    final Color barColor;
    if (achievement.isUnlocked) {
      barColor = AppColors.featherGreen;
    } else if (achievement.isInProgress) {
      barColor = AppColors.bee;
    } else {
      barColor = AppColors.hare;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.polar,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tiến trình',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.eel,
                ),
              ),
              Text(
                '$progress / $requirement',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: achievement.isUnlocked
                      ? AppColors.featherGreen
                      : AppColors.wolf,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 10,
              backgroundColor: AppColors.swan,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          if (achievement.isUnlocked) ...[
            const SizedBox(height: 8),
            Text(
              '${(percentage * 100).toInt()}% hoàn thành',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.featherGreen,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Rewards section
  // ---------------------------------------------------------------------------
  Widget _buildRewardsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.polar,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Phần thưởng',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.eel,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (achievement.achievement.rewardXp > 0)
                _RewardBadge(
                  icon: Icons.star_rounded,
                  color: AppColors.bee,
                  value: '${achievement.achievement.rewardXp}',
                  label: 'XP',
                ),
              if (achievement.achievement.rewardGems > 0)
                _RewardBadge(
                  icon: Icons.diamond_rounded,
                  color: AppColors.macaw,
                  value: '${achievement.achievement.rewardGems}',
                  label: 'Gems',
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tier + Category info row
  // ---------------------------------------------------------------------------
  Widget _buildInfoRow() {
    final tierColor = _getTierColor(achievement.achievement.tier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: tierColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: tierColor.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getTierIcon(achievement.achievement.tier),
                size: 16,
                color: tierColor,
              ),
              const SizedBox(width: 4),
              Text(
                achievement.achievement.tierLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: tierColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.polar,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.swan),
          ),
          child: Text(
            _getCategoryLabel(achievement.achievement.category),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.wolf,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  Color _getTierColor(int tier) {
    switch (tier) {
      case 1:
        return const Color(0xFFCD7F32); // Bronze
      case 2:
        return const Color(0xFF9CA3AF); // Silver
      case 3:
        return const Color(0xFFD4AF37); // Gold
      case 4:
        return const Color(0xFF06B6D4); // Platinum
      case 5:
        return AppColors.beetle; // Diamond purple
      default:
        return AppColors.wolf;
    }
  }

  IconData _getTierIcon(int tier) {
    switch (tier) {
      case 5:
        return Icons.diamond_rounded;
      case 4:
        return Icons.workspace_premium_rounded;
      default:
        return Icons.shield_rounded;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category.toLowerCase()) {
      case 'streak':
        return 'Streak';
      case 'lessons':
        return 'Bài học';
      case 'xp':
        return 'Kinh nghiệm';
      case 'social':
        return 'Xã hội';
      case 'personal':
        return 'Cá nhân';
      default:
        return category;
    }
  }
}

/// Individual reward item with icon, value and label
class _RewardBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _RewardBadge({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
