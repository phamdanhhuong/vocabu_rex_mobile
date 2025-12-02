import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/achievement/domain/entities/achievement_entity.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

/// Achievement tile for grid view in "Awards" section
class AchievementTile extends StatelessWidget {
  final AchievementEntity achievement;
  final VoidCallback? onTap;

  const AchievementTile({
    Key? key,
    required this.achievement,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLocked = !achievement.isUnlocked && achievement.progress == 0;
    final progressText = achievement.isUnlocked
        ? 'Hoàn thành'
        : achievement.progress > 0
            ? '${achievement.progress}/${achievement.achievement.requirement}'
            : 'Chưa có';

    // Normalize achievement name to match asset naming pattern
    String normalizeAssetName(String name) {
      // Convert to lowercase and replace spaces with underscores
      String normalized = name.toLowerCase().replaceAll(' ', '_');
      
      // Remove common suffixes and patterns
      normalized = normalized.replaceAll(RegExp(r'_t[0-9]+$'), ''); // Remove tier suffix like _t1, _t2
      normalized = normalized.replaceAll(RegExp(r'_[0-9]+$'), ''); // Remove numeric suffix
      
      return normalized;
    }

    // Determine badge asset based on progress
    String getBadgeAsset() {
      final requirement = achievement.achievement.requirement;
      final isFull = requirement > 0 && achievement.progress >= requirement;
      final suffix = isFull ? '_done.png' : '_doing.png';
      
      // Use fuzzy matching based on achievement name
      String baseName = normalizeAssetName(achievement.achievement.name);
      
      return 'assets/achivements/$baseName$suffix';
    }

    // Grayscale color filter matrix
    const greyscaleMatrix = <double>[
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0, 0, 0, 1, 0,
    ];

    Widget buildBadge() {
      final badgeAsset = getBadgeAsset();
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

      // Apply grayscale filter for locked achievements
      if (isLocked) {
        return ColorFiltered(
          colorFilter: const ColorFilter.matrix(greyscaleMatrix),
          child: Opacity(opacity: 0.4, child: img),
        );
      }

      return img;
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Badge image
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                buildBadge(),
                
                // Tier badge (only if not locked)
                if (!isLocked)
                  Positioned(
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        achievement.achievement.tier.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                
                // Lock icon for locked achievements
                if (isLocked)
                  const Icon(
                    Icons.lock,
                    color: Colors.grey,
                    size: 28,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Achievement name
          Text(
            achievement.achievement.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isLocked ? const Color(0xFF777777) : AppColors.bodyText,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          
          // Progress text
          Text(
            progressText,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF777777),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
