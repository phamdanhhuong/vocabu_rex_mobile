import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:vocabu_rex_mobile/content/content_page.dart';
import 'package:vocabu_rex_mobile/web/widgets/web_left_sidebar.dart';
import 'package:vocabu_rex_mobile/web/widgets/web_right_panel.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

// ── Pages (same as ContentPage) ──
import 'package:vocabu_rex_mobile/home/ui/pages/home_page.dart';
import 'package:vocabu_rex_mobile/quest/ui/pages/quest_page.dart';
import 'package:vocabu_rex_mobile/leaderboard/ui/pages/leaderboard_page.dart';
import 'package:vocabu_rex_mobile/feed/ui/pages/feed_page.dart';
import 'package:vocabu_rex_mobile/assistant/ui/pages/assistant_page.dart';
import 'package:vocabu_rex_mobile/more/ui/pages/more_page.dart';
import 'package:vocabu_rex_mobile/profile/ui/pages/profile_page.dart';
import 'package:vocabu_rex_mobile/pronunciation/ui/pages/pronunciation_page.dart';
import 'package:vocabu_rex_mobile/more/ui/pages/video_call_page.dart';
import 'package:vocabu_rex_mobile/more/ui/pages/practice_center_page.dart';

// ── BLoCs ──
import 'package:vocabu_rex_mobile/home/ui/blocs/home_bloc.dart';
import 'package:vocabu_rex_mobile/currency/ui/blocs/currency_bloc.dart';
import 'package:vocabu_rex_mobile/streak/ui/blocs/streak_bloc.dart';
import 'package:vocabu_rex_mobile/streak/ui/blocs/streak_event.dart';
import 'package:vocabu_rex_mobile/energy/ui/blocs/energy_bloc.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/quest_bloc.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/quest_event.dart';
import 'package:vocabu_rex_mobile/leaderboard/ui/blocs/leaderboard_bloc.dart';
import 'package:vocabu_rex_mobile/leaderboard/ui/blocs/leaderboard_event.dart';

/// Responsive shell that dynamically switches between:
/// - **Web layout** (≥ 768px): sidebar + content + right panel
/// - **Mobile layout** (< 768px): ContentPage with bottom nav
///
/// On native mobile, always uses ContentPage.
/// On web, responds to window resize in real-time via LayoutBuilder.
///
/// This widget is the single owner of ShowcaseView, pages,
/// navigation state, and initial data fetching — avoiding
/// dispose/init conflicts when switching layouts.
class ResponsiveShell extends StatefulWidget {
  static const double webBreakpoint = 768.0;
  const ResponsiveShell({super.key});

  @override
  State<ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends State<ResponsiveShell> {
  int _selectedIndex = 0;

  late final List<Widget> _pages = const [
    HomePage(),           // 0
    QuestsPage(),         // 1
    LeaderBoardPage(),    // 2
    FeedPage(),           // 3
    AssistantPage(),      // 4
    More(),               // 5
    ProfilePage(),        // 6
    PronunciationPage(),  // 7
    VideoCallPage(),      // 8
    PracticeCenterPage(), // 9
  ];

  @override
  void initState() {
    super.initState();

    // Register ShowcaseView ONCE (web only — mobile ContentPage has its own)
    if (kIsWeb) {
      ShowcaseView.register(blurValue: 1.0);
    }

    // Fetch initial data on web
    if (kIsWeb) {
      Future.microtask(() {
        if (!mounted) return;
        context.read<HomeBloc>().add(GetUserProgressEvent());
        context.read<CurrencyBloc>().add(GetCurrencyBalanceEvent(''));
        context.read<StreakBloc>().add(GetStreakHistoryEvent());
        context.read<EnergyBloc>().add(GetEnergyStatusEvent());
        context.read<QuestBloc>().add(GetUserQuestsEvent());
        context.read<LeaderboardBloc>().add(LoadLeaderboardEvent());
      });
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      try {
        ShowcaseView.get().unregister();
      } catch (_) {
        // Safely ignore if already unregistered
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // On native mobile, always use the original ContentPage
    if (!kIsWeb) {
      return const ContentPage();
    }

    // On web, use LayoutBuilder to respond to resize
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= ResponsiveShell.webBreakpoint;

        if (isWideScreen) {
          return _buildWebLayout(constraints.maxWidth);
        } else {
          return _buildMobileLayout();
        }
      },
    );
  }

  // ── Web layout: sidebar + center + right panel ──
  Widget _buildWebLayout(double screenWidth) {
    final showRightPanel = screenWidth >= 1100;

    return Scaffold(
      backgroundColor: AppColors.polar,
      body: Row(
        children: [
          WebLeftSidebar(
            selectedIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
          ),
          Expanded(
            child: Container(
              color: AppColors.polar,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: KeyedSubtree(
                      key: ValueKey<int>(_selectedIndex),
                      child: _pages[_selectedIndex],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (showRightPanel) const WebRightPanel(),
        ],
      ),
    );
  }

  // ── Mobile layout on web (narrow window): bottom nav ──
  Widget _buildMobileLayout() {
    // Render pages inline (no dropdown More — simplified for web narrow mode)
    return Scaffold(
      backgroundColor: AppColors.snow,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: KeyedSubtree(
          key: ValueKey<int>(_selectedIndex),
          child: _pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex > 5 ? 5 : _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.macaw,
        unselectedItemColor: AppColors.wolf,
        backgroundColor: AppColors.snow,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Học'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Nhiệm vụ'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'BXH'),
          BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'Bảng tin'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'Trợ lý'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'Thêm'),
        ],
      ),
    );
  }
}
