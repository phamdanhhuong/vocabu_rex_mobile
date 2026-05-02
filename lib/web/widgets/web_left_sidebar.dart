import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

/// Left sidebar navigation for web layout (Duolingo-style).
/// Uses the same PNG icon assets as the mobile bottom nav.
class WebLeftSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const WebLeftSidebar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  static const _navItems = <_NavItem>[
    _NavItem(imageAsset: 'assets/icons/learn.png', label: 'Học', pageIndex: 0),
    _NavItem(
      imageAsset: 'assets/icons/reward.png',
      label: 'Nhiệm vụ',
      pageIndex: 1,
    ),
    _NavItem(
      imageAsset: 'assets/icons/quest.png',
      label: 'Bảng xếp hạng',
      pageIndex: 2,
    ),
    _NavItem(
      imageAsset: 'assets/icons/feed.png',
      label: 'Bảng tin',
      pageIndex: 3,
    ),
    _NavItem(
      imageAsset: 'assets/icons/friend.png',
      label: 'Trợ lý',
      pageIndex: 4,
    ),
    _NavItem(
      imageAsset: 'assets/icons/profile.png',
      label: 'Hồ sơ',
      pageIndex: 6,
    ),
    _NavItem(
      imageAsset: 'assets/icons/speech.png',
      label: 'Thi đấu',
      pageIndex: 7,
    ),
    _NavItem(
      imageAsset: 'assets/icons/more.png',
      label: 'Cài đặt',
      pageIndex: 5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: AppColors.snow,
        border: Border(right: BorderSide(color: AppColors.swan, width: 2)),
      ),
      child: Column(
        children: [
          SizedBox(height: 20),

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
                    child: Icon(
                      Icons.auto_stories,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Text(
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

          SizedBox(height: 16),

          // ── Nav Items ──
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _navItems.length,
              separatorBuilder: (_, __) => SizedBox(height: 4),
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = item.pageIndex == selectedIndex;

                return _NavTile(
                  imageAsset: item.imageAsset,
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
  final String imageAsset;
  final String label;
  final int pageIndex;
  const _NavItem({
    required this.imageAsset,
    required this.label,
    required this.pageIndex,
  });
}

class _NavTile extends StatefulWidget {
  final String imageAsset;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavTile({
    required this.imageAsset,
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
              Image.asset(
                widget.imageAsset,
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 14),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: widget.isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
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
