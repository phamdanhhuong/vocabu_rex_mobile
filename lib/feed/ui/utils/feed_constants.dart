import 'package:flutter/material.dart';

// Post type icons and colors
class PostTypeConfig {
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const PostTypeConfig({
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  static const Map<String, PostTypeConfig> configs = {
    'STREAK_MILESTONE': PostTypeConfig(
      icon: Icons.local_fire_department,
      color: Color(0xFFFF5722),
      backgroundColor: Color(0xFFFFEBEE),
    ),
    'LEAGUE_PROMOTION': PostTypeConfig(
      icon: Icons.military_tech,
      color: Color(0xFFFFD700),
      backgroundColor: Color(0xFFFFF9E6),
    ),
    'LEAGUE_TOP_3': PostTypeConfig(
      icon: Icons.emoji_events,
      color: Color(0xFFFF9800),
      backgroundColor: Color(0xFFFFF3E0),
    ),
    'NEW_FOLLOWER': PostTypeConfig(
      icon: Icons.people,
      color: Color(0xFF2196F3),
      backgroundColor: Color(0xFFE3F2FD),
    ),
    'ACHIEVEMENT_UNLOCKED': PostTypeConfig(
      icon: Icons.stars,
      color: Color(0xFF9C27B0),
      backgroundColor: Color(0xFFF3E5F5),
    ),
    'LEVEL_UP': PostTypeConfig(
      icon: Icons.trending_up,
      color: Color(0xFF4CAF50),
      backgroundColor: Color(0xFFE8F5E9),
    ),
    'QUEST_COMPLETED': PostTypeConfig(
      icon: Icons.task_alt,
      color: Color(0xFF00BCD4),
      backgroundColor: Color(0xFFE0F7FA),
    ),
    'PERFECT_SCORE': PostTypeConfig(
      icon: Icons.star,
      color: Color(0xFFFFEB3B),
      backgroundColor: Color(0xFFFFFDE7),
    ),
    'XP_MILESTONE': PostTypeConfig(
      icon: Icons.auto_awesome,
      color: Color(0xFF673AB7),
      backgroundColor: Color(0xFFEDE7F6),
    ),
  };

  static PostTypeConfig getConfig(String postType) {
    return configs[postType] ??
        const PostTypeConfig(
          icon: Icons.celebration,
          color: Color(0xFF9E9E9E),
          backgroundColor: Color(0xFFF5F5F5),
        );
  }
}
