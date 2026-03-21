import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

/// Left sidebar navigation for web layout (Duolingo-style).
class WebLeftSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const WebLeftSidebar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  static const _navItems = <_NavItem>[
    _NavItem(icon: Icons.school_outlined, activeIcon: Icons.school, label: 'Học', pageIndex: 0),
    _NavItem(icon: Icons.emoji_events_outlined, activeIcon: Icons.emoji_events, label: 'Nhiệm vụ', pageIndex: 1),
    _NavItem(icon: Icons.leaderboard_outlined, activeIcon: Icons.leaderboard, label: 'Bảng xếp hạng', pageIndex: 2),
    _NavItem(icon: Icons.feed_outlined, activeIcon: Icons.feed, label: 'Bảng tin', pageIndex: 3),
    _NavItem(icon: Icons.smart_toy_outlined, activeIcon: Icons.smart_toy, label: 'Trợ lý', pageIndex: 4),
    _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Hồ sơ', pageIndex: 6),
    _NavItem(icon: Icons.mic_none_outlined, activeIcon: Icons.mic, label: 'Phát âm', pageIndex: 7),
    _NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Cài đặt', pageIndex: 5),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: AppColors.snow,
        border: Border(
          right: BorderSide(color: AppColors.swan, width: 2),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // ── Logo ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 44,
                  height: 44,
                  errorBuilder: (_, __, ___) => Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.featherGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_stories, color: Colors.white, size: 28),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'VocabuRex',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.featherGreen,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Nav Items ──
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _navItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = item.pageIndex == selectedIndex;

                return _NavTile(
                  icon: isSelected ? item.activeIcon : item.icon,
                  label: item.label,
                  isSelected: isSelected,
                  onTap: () => onTap(item.pageIndex),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int pageIndex;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.pageIndex,
  });
}

class _NavTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.selectionBlueLight
                : (_isHovered ? AppColors.polar : Colors.transparent),
            borderRadius: BorderRadius.circular(14),
            border: widget.isSelected
                ? Border.all(color: AppColors.macaw, width: 2)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 26,
                color: widget.isSelected ? AppColors.macaw : AppColors.wolf,
              ),
              const SizedBox(width: 14),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: widget.isSelected ? AppColors.macaw : AppColors.eel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
