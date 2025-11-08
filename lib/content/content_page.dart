import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/assistant/ui/pages/assistant_page.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/quest/ui/pages/quest_page.dart';
import 'package:vocabu_rex_mobile/theme/widgets/navigations/app_bottom_navigation.dart';
import 'package:vocabu_rex_mobile/home/ui/pages/home_page.dart';
import 'package:vocabu_rex_mobile/leaderboard/ui/pages/leaderboard_page.dart';
import 'package:vocabu_rex_mobile/newfeed/ui/pages/newfeed_page.dart';
import 'package:vocabu_rex_mobile/more/ui/pages/more_page.dart';

class ContentPage extends StatefulWidget {
  const ContentPage({Key? key}) : super(key: key);

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    QuestsPage(),
    LeaderBoardPage(),
    NewFeedPage(),
    AssistantPage(),
    // Note: "More" is shown as a modal bottom sheet instead of a dedicated page.
  ];

  void _onItemTapped(int index) {
    // If the More tab (last tab) is tapped, show the modal and don't change the body.
    if (index == 5) {
      _showMoreModal();
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _showMoreModal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MoreSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.snow,
      body: _pages[_selectedIndex],
      bottomNavigationBar: AppBottomNav(
        items: const [
          AppBottomNavItem(imageAssetPath: 'assets/icons/learn.png', label: 'Học'),
          AppBottomNavItem(imageAssetPath: 'assets/icons/reward.png', label: 'Nhiệm vụ'),
          AppBottomNavItem(imageAssetPath: 'assets/icons/quest.png', label: 'Bảng xếp hạng'),
          AppBottomNavItem(imageAssetPath: 'assets/icons/feed.png', label: 'Bảng tin'),
          AppBottomNavItem(imageAssetPath: 'assets/icons/friend.png', label: 'Trợ lý'),
          AppBottomNavItem(imageAssetPath: 'assets/icons/more.png', label: 'Thêm'),
        ],
        initialIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
