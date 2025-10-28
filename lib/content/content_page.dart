import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/assistant/ui/pages/assistant_page.dart';
import 'package:vocabu_rex_mobile/pronunciation/ui/pages/pronunciation_page.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/navigations/app_bottom_navigation.dart';
import 'package:vocabu_rex_mobile/home/ui/pages/home_page.dart';
import 'package:vocabu_rex_mobile/profile/ui/pages/profile_page.dart';
// import các trang khác nếu cần

class ContentPage extends StatefulWidget {
  const ContentPage({Key? key}) : super(key: key);

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    PronunciationPage(),
    Center(
      child: Text("Leaderboard", style: TextStyle(color: AppColors.textWhite)),
    ),
    AssistantPage(),
    ProfilePage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: _pages[_selectedIndex],
      bottomNavigationBar: AppBottomNav(
        items: const [
          AppBottomNavItem(imageAssetPath: 'assets/icons/learn.png', label: 'Học'),
          AppBottomNavItem(imageAssetPath: 'assets/icons/speech.png', label: 'Phát âm'),
          AppBottomNavItem(imageAssetPath: 'assets/icons/reward.png', label: 'Leaderboard'),
          AppBottomNavItem(imageAssetPath: 'assets/icons/shop.png', label: 'Trợ lý'),
          AppBottomNavItem(imageAssetPath: 'assets/icons/profile.png', label: 'Profile'),
          AppBottomNavItem(imageAssetPath: 'assets/icons/more.png', label: 'More'),
        ],
        initialIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
