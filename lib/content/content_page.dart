import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';
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
    Center(child: Text("Luyện phát âm", style: TextStyle(color: AppColors.textWhite))),
    Center(child: Text("Leaderboard", style: TextStyle(color: AppColors.textWhite))),
    Center(child: Text("Quest", style: TextStyle(color: AppColors.textWhite))),
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.borderGrey,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: AppColors.appBarColor,
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.record_voice_over),
              label: "Phát âm",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events),
              label: "Leaderboard",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.extension),
              label: "Quest",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
