import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/achievement/domain/entities/achievement_entity.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

/// Achievement detail dialog/bottom sheet
class AchievementDetailDialog extends StatelessWidget {
  final AchievementEntity achievement;

  const AchievementDetailDialog({
    Key? key,
    required this.achievement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLocked = !achievement.isUnlocked && achievement.progress == 0;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge image
            SizedBox(
              height: 120,
              width: 120,
              child: Builder(
                builder: (context) {
                  // Determine badge asset
                  final requirement = achievement.achievement.requirement;
                  final isFull = requirement > 0 && achievement.progress >= requirement;
                  final suffix = isFull ? '_done.png' : '_doing.png';
                  
                  String baseName = achievement.achievement.key;
                  if (achievement.achievement.badgeUrl != null && achievement.achievement.badgeUrl!.isNotEmpty) {
                    baseName = achievement.achievement.badgeUrl!.split('/').last.replaceAll('.png', '').replaceAll('.jpg', '');
                  } else if (achievement.achievement.iconUrl != null && achievement.achievement.iconUrl!.isNotEmpty) {
                    baseName = achievement.achievement.iconUrl!.split('/').last.replaceAll('.png', '').replaceAll('.jpg', '');
                  }
                  
                  final badgeAsset = 'assets/achivements/$baseName$suffix';
                  
                  // Grayscale filter for locked
                  const greyscaleMatrix = <double>[
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0, 0, 0, 1, 0,
                  ];
                  
                  Widget img = Image.asset(
                    badgeAsset,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        achievement.achievement.categoryIcon,
                        fit: BoxFit.contain,
                      );
                    },
                  );
                  
                  Widget badge = isLocked
                      ? ColorFiltered(
                          colorFilter: const ColorFilter.matrix(greyscaleMatrix),
                          child: Opacity(opacity: 0.4, child: img),
                        )
                      : img;
                  
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      badge,
                      if (isLocked)
                        const Icon(
                          Icons.lock,
                          color: Colors.grey,
                          size: 48,
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            
            // Achievement name
            Text(
              achievement.achievement.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.bodyText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Achievement description
            Text(
              achievement.achievement.description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF777777),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Progress bar (if in progress)
            if (achievement.isInProgress) ...[
              LinearProgressIndicator(
                value: achievement.progressPercentage,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.featherGreen),
              ),
              const SizedBox(height: 8),
              Text(
                '${achievement.progress}/${achievement.achievement.requirement}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.bodyText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Rewards section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Phần thưởng',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.bodyText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // XP reward
                      if (achievement.achievement.rewardXp > 0)
                        _RewardItem(
                          icon: Icons.star,
                          color: Colors.amber,
                          label: '${achievement.achievement.rewardXp} XP',
                        ),
                      
                      // Gems reward
                      if (achievement.achievement.rewardGems > 0)
                        _RewardItem(
                          icon: Icons.diamond,
                          color: Colors.blue,
                          label: '${achievement.achievement.rewardGems} Gems',
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Tier and category info
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Chip(
                  label: Text(achievement.achievement.tierLabel),
                  backgroundColor: _getTierColor(achievement.achievement.tier),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(_getCategoryLabel(achievement.achievement.category)),
                  backgroundColor: Colors.grey[200],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Close button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTierColor(int tier) {
    switch (tier) {
      case 1:
        return Colors.brown[300]!;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.amber[300]!;
      case 4:
        return Colors.cyan[300]!;
      case 5:
        return Colors.purple[300]!;
      default:
        return Colors.grey[300]!;
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
      default:
        return category;
    }
  }
}

class _RewardItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _RewardItem({
    Key? key,
    required this.icon,
    required this.color,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.bodyText,
          ),
        ),
      ],
    );
  }
}
