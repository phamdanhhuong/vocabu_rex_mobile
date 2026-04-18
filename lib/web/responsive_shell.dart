import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:vocabu_rex_mobile/content/content_page.dart';
import 'package:vocabu_rex_mobile/web/widgets/web_left_sidebar.dart';
import 'package:vocabu_rex_mobile/web/widgets/web_right_panel.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/navigations/app_bottom_navigation.dart';

// ── Pages (same as ContentPage) ──
import 'package:vocabu_rex_mobile/home/ui/pages/home_page.dart';
import 'package:vocabu_rex_mobile/quest/ui/pages/quest_page.dart';
import 'package:vocabu_rex_mobile/leaderboard/ui/pages/leaderboard_page.dart';
import 'package:vocabu_rex_mobile/feed/ui/pages/feed_page.dart';
import 'package:vocabu_rex_mobile/assistant/ui/pages/assistant_page.dart';
import 'package:vocabu_rex_mobile/more/ui/pages/more_page.dart';
import 'package:vocabu_rex_mobile/profile/ui/pages/profile_page.dart';
import 'package:vocabu_rex_mobile/battle/ui/pages/battle_page.dart';
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

class _ResponsiveShellState extends State<ResponsiveShell>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;

  // For mobile layout "More" dropdown
  AnimationController? _dropdownAnimationController;
  Animation<Offset>? _dropdownAnimation;
  bool _showMoreDropdown = false;

  late final List<Widget> _pages = const [
    HomePage(),           // 0
    QuestsPage(),         // 1
    LeaderBoardPage(),    // 2
    FeedPage(),           // 3
    AssistantPage(),      // 4
    More(),               // 5
    ProfilePage(),        // 6
    BattlePage(),          // 7
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
    _dropdownAnimationController?.dispose();
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
    return Scaffold(
      backgroundColor: AppColors.snow,
      body: Stack(
        children: [
          // Main content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: KeyedSubtree(
              key: ValueKey<int>(_selectedIndex),
              child: _pages[_selectedIndex],
            ),
          ),
          
          // More dropdown overlay
          if (_showMoreDropdown && _dropdownAnimation != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SlideTransition(
                position: _dropdownAnimation!,
                child: Material(
                  color: Colors.transparent,
                  child: MoreSheet(
                    currentSelectedIndex: _selectedIndex,
                    onOptionSelected: (pageIndex) {
                      _hideMoreDropdown();
                      setState(() {
                        _selectedIndex = pageIndex;
                      });
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        items: const [
          AppBottomNavItem(imageAssetPath: 'assets/icons/learn.png', label: 'Học'),
          AppBottomNavItem(imageAssetPath: 'assets/icons/reward.png', label: 'Nhiệm vụ'),
          AppBottomNavItem(imageAssetPath: 'assets/icons/quest.png', label: 'Bảng xếp hạng'),
          AppBottomNavItem(imageAssetPath: 'assets/icons/feed.png', label: 'Bảng tin'),
          AppBottomNavItem(imageAssetPath: 'assets/icons/friend.png', label: 'Trợ lý'),
          AppBottomNavItem(imageAssetPath: 'assets/icons/more.png', label: 'Thêm'),
        ],
        showcaseKeys: [], // No showcase in narrow web mode
        initialIndex: _selectedIndex > 5 ? 5 : _selectedIndex,
        onTap: _onMobileItemTapped,
      ),
    );
  }

  void _onMobileItemTapped(int index) {
    if (index == 5) {
      _toggleMoreDropdown();
      return;
    }

    if (_showMoreDropdown) {
      _hideMoreDropdown();
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleMoreDropdown() {
    if (_showMoreDropdown) {
      _hideMoreDropdown();
    } else {
      _showDropdown();
    }
  }

  void _showDropdown() {
    _dropdownAnimationController ??= AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _dropdownAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _dropdownAnimationController!,
        curve: Curves.easeOut,
      ),
    );

    setState(() {
      _showMoreDropdown = true;
    });

    _dropdownAnimationController!.forward(from: 0.0);
  }

  void _hideMoreDropdown() {
    _dropdownAnimationController?.reverse().then((_) {
      if (mounted) {
        setState(() {
          _showMoreDropdown = false;
        });
      }
    });
  }
}
