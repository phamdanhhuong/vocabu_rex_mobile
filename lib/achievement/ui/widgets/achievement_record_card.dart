import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/achievement/domain/entities/achievement_entity.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:intl/intl.dart';

/// Achievement card for "Recent Achievements" section
class AchievementRecordCard extends StatelessWidget {
  final AchievementEntity achievement;

  const AchievementRecordCard({
    Key? key,
    required this.achievement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM, yyyy');
    final dateStr = achievement.unlockedAt != null
        ? dateFormat.format(achievement.unlockedAt!)
        : '';

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 2.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge image with tier level
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Badge image - always use _done.png for unlocked achievements
                Builder(
                  builder: (context) {
                    // Use fuzzy matching based on achievement name
                    String baseName = _normalizeAssetName(achievement.achievement.name);
                    final badgeAsset = 'assets/achivements/$baseName.png';
                    
                    return Image.asset(
                      badgeAsset,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          achievement.achievement.categoryIcon,
                          fit: BoxFit.contain,
                        );
                      },
                    );
                  },
                ),
                
                // Tier level
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      achievement.achievement.tier.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Achievement name
          Text(
            achievement.achievement.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.bodyText,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          
          // Unlocked date
          Text(
            dateStr,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF777777),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Normalize achievement name to match asset naming pattern
  String _normalizeAssetName(String name) {
    // Convert to lowercase and replace spaces with underscores
    String normalized = name.toLowerCase().replaceAll(' ', '_');
    
    // Remove common suffixes and patterns
    normalized = normalized.replaceAll(RegExp(r'_t[0-9]+$'), ''); // Remove tier suffix like _t1, _t2
    normalized = normalized.replaceAll(RegExp(r'_[0-9]+$'), ''); // Remove numeric suffix
    
    return normalized;
  }
}
