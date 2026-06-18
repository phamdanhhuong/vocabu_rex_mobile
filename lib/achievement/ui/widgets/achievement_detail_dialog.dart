import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/achievement/domain/entities/achievement_entity.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import 'package:animate_do/animate_do.dart';

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

    return ListenableBuilder(
      listenable: AppPreferences(),
      builder: (context, _) {
        Widget dialogContent = Container(
          color: AppColors.snow,
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
                    FadeInUp(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        achievement.achievement.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.eel,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Description
                    FadeInUp(
                      duration: const Duration(milliseconds: 400),
                      child: Text(
                        achievement.achievement.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.wolf,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Status chip
                    FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      child: _buildStatusChip(),
                    ),
                    const SizedBox(height: 20),

                    // Progress section
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      child: _buildProgressSection(),
                    ),
                    const SizedBox(height: 16),

                    // Rewards section
                    if (achievement.achievement.rewardXp > 0 ||
                        achievement.achievement.rewardGems > 0) ...[
                      FadeInUp(
                        duration: const Duration(milliseconds: 700),
                        child: _buildRewardsSection(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Tier + Category row
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      child: _buildInfoRow(),
                    ),
                    const SizedBox(height: 20),

                    // Close button
                    FadeInUp(
                      duration: const Duration(milliseconds: 900),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.swan,
                            foregroundColor: AppColors.eel,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'ĐÓNG',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        final bool isLedBorder = achievement.isUnlocked && achievement.achievement.tier >= 4;

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: BounceInDown(
            duration: const Duration(milliseconds: 600),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 360),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: isLedBorder ? AppColors.macaw.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.12),
                    blurRadius: isLedBorder ? 32 : 24,
                    spreadRadius: isLedBorder ? 4 : 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: isLedBorder 
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        // LED border background
                        Spin(
                          infinite: true,
                          duration: const Duration(seconds: 3),
                          child: Container(
                            width: 600, // Large enough to cover rotation
                            height: 600,
                            decoration: const BoxDecoration(
                              gradient: SweepGradient(
                                colors: [
                                  AppColors.macaw,
                                  Colors.transparent,
                                  AppColors.beetle,
                                  Colors.transparent,
                                  AppColors.macaw,
                                ],
                                stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                              ),
                            ),
                          ),
                        ),
                        // Inner dialog content with padding serving as border width
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: dialogContent,
                          ),
                        ),
                      ],
                    )
                  : dialogContent,
              ),
            ),
          ),
        );

      },
    );
  }

  // ---------------------------------------------------------------------------
  // Header with gradient background + badge image
  // ---------------------------------------------------------------------------
  Widget _buildHeader(BuildContext context, bool isLocked) {
    final Color headerColor;
    final Color headerColorLight;

    final int tier = achievement.achievement.tier;

    if (achievement.isUnlocked) {
      if (tier >= 5) {
        headerColor = AppColors.beetle;
        headerColorLight = AppColors.macaw;
      } else if (tier >= 3) {
        headerColor = const Color(0xFFFFC107);
        headerColorLight = const Color(0xFFFFE066);
      } else {
        headerColor = AppColors.featherGreen;
        headerColorLight = AppColors.maskGreen;
      }
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
          // Glow ring / Sun burst for unlocked
          if (achievement.isUnlocked)
            if (tier >= 3)
              Spin(
                infinite: true,
                duration: const Duration(seconds: 10),
                child: Icon(
                  Icons.settings, // Using settings icon as a sun burst shape
                  size: 180,
                  color: headerColorLight.withValues(alpha: 0.3),
                ),
              )
            else
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: headerColor.withValues(alpha: 0.25),
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
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: percentage),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor: AppColors.swan,
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                );
              },
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
    return Column(
      children: [
        Text(
          'PHẦN THƯỞNG',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: AppColors.wolf,
            letterSpacing: 1.2,
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
                label: 'GEMS',
              ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Tier + Category info row
  // ---------------------------------------------------------------------------
  Widget _buildInfoRow() {
    final tierColor = _getTierColor(achievement.achievement.tier);
    final tierLabel = achievement.achievement.tierLabel;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Tier Badge
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [tierColor.withValues(alpha: 0.2), tierColor.withValues(alpha: 0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: tierColor.withValues(alpha: 0.3), width: 1.5),
              boxShadow: [
                BoxShadow(color: tierColor.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4)),
              ]
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getTierIcon(achievement.achievement.tier),
                  size: 18,
                  color: tierColor,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    tierLabel.toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: tierColor,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Category Badge
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.snow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.swan, width: 1.5),
              boxShadow: [
                BoxShadow(color: AppColors.swan.withValues(alpha: 0.5), blurRadius: 8, offset: const Offset(0, 4)),
              ]
            ),
            child: Text(
              _getCategoryLabel(achievement.achievement.category).toUpperCase(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: AppColors.wolf,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
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
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: color.withValues(alpha: 0.8),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
