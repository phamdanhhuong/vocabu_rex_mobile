import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:vocabu_rex_mobile/assistant/ui/pages/assistant_page.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/fab_cubit.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/show_case_cubit.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/quest/ui/pages/quest_page.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:vocabu_rex_mobile/theme/widgets/navigations/app_bottom_navigation.dart';
import 'package:vocabu_rex_mobile/home/ui/pages/home_page.dart';
import 'package:vocabu_rex_mobile/leaderboard/ui/pages/leaderboard_page.dart';
import 'package:vocabu_rex_mobile/newfeed/ui/pages/newfeed_page.dart';
import 'package:vocabu_rex_mobile/more/ui/pages/more_page.dart';
import 'package:vocabu_rex_mobile/profile/ui/pages/profile_page.dart';
import 'package:vocabu_rex_mobile/pronunciation/ui/pages/pronunciation_page.dart';
import 'package:vocabu_rex_mobile/more/ui/pages/video_call_page.dart';
import 'package:vocabu_rex_mobile/more/ui/pages/practice_center_page.dart';

class ContentPage extends StatefulWidget {
  const ContentPage({Key? key}) : super(key: key);

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> with TickerProviderStateMixin {
  final GlobalKey _learnTabKey = GlobalKey();
  final GlobalKey _questTabKey = GlobalKey();
  final GlobalKey _leaderboardTabKey = GlobalKey();
  final GlobalKey _newFeedTabKey = GlobalKey();
  final GlobalKey _assistantTabKey = GlobalKey();
  final GlobalKey _moreTabKey = GlobalKey();

  int _selectedIndex = 0;
  AnimationController? _dropdownAnimationController;
  Animation<Offset>? _dropdownAnimation;
  bool _showMoreDropdown = false;

  late final List<Widget> _pages = [
    const HomePage(),
    const QuestsPage(),
    const LeaderBoardPage(),
    const NewFeedPage(),
    const AssistantPage(),
    const More(), // Placeholder for More tab
    const ProfilePage(),
    const PronunciationPage(),
    const VideoCallPage(),
    const PracticeCenterPage(),
  ];

  void _onItemTapped(int index) {
    // If the More tab (last tab) is tapped, show the dropdown overlay
    if (index == 5) {
      _toggleMoreDropdown();
      return;
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
    _dropdownAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _dropdownAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _dropdownAnimationController!,
      curve: Curves.easeOut,
    ));

    setState(() {
      _showMoreDropdown = true;
    });

    _dropdownAnimationController!.forward();
  }

  void _hideMoreDropdown() {
    _dropdownAnimationController?.reverse().then((_) {
      setState(() {
        _showMoreDropdown = false;
      });
      _dropdownAnimationController?.dispose();
      _dropdownAnimationController = null;
      _dropdownAnimation = null;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ShowcaseView.register(
      // Tùy chọn: đặt các action mặc định như Next/Previous ở đây
      blurValue: 1.0,
      globalFloatingActionWidget: (showcaseContext) => FloatingActionWidget(
        right: 5.w,
        bottom: 150.h,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AppButton(
            onPressed: () => ShowcaseView.get().dismiss(),
            label: "Bỏ qua hướng dẫn",
            width: 100.w,
          ),
        ),
      ),
      onDismiss: (key) {
        // Logic để lưu trạng thái (người dùng đã xem xong showcase)
      },
    );
  }

  @override
  void dispose() {
    _dropdownAnimationController?.dispose();
    super.dispose();
    ShowcaseView.get().unregister();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ShowCaseCubit, ShowcaseState>(
          listenWhen: (previous, current) {
            return previous.hasSeenNavBarShowcase !=
                current.hasSeenNavBarShowcase;
          },
          listener: (context, state) {
            final cubit = context.read<ShowCaseCubit>();
            if (!state.hasSeenNavBarShowcase) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final flagKey = cubit.getKey('flag');
                final streakKey = cubit.getKey('streak');
                final gemKey = cubit.getKey('gem');
                final coinKey = cubit.getKey('coin');
                final heartKey = cubit.getKey('heart');
                // Khởi động chuỗi hướng dẫn
                ShowcaseView.get().startShowCase([
                  _learnTabKey,
                  _questTabKey,
                  _leaderboardTabKey,
                  _newFeedTabKey,
                  _assistantTabKey,
                  _moreTabKey,
                  flagKey!,
                  streakKey!,
                  gemKey!,
                  coinKey!,
                  heartKey!,
                ]);
              });
              context.read<ShowCaseCubit>().markNavBarShowcaseSeen();
            }
          },
        ),
        BlocListener<ShowCaseCubit, ShowcaseState>(
          listenWhen: (previous, current) {
            return previous.hasSeenLessonShowcase !=
                current.hasSeenLessonShowcase;
          },
          listener: (context, state) {
            final cubit = context.read<ShowCaseCubit>();
            if (!state.hasSeenLessonShowcase) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final nodeKey = cubit.getKey('node');
                // Khởi động chuỗi hướng dẫn
                ShowcaseView.get().startShowCase([nodeKey!]);
              });
              context.read<ShowCaseCubit>().markLessonShowcaseSeen();
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.snow,
        body: Stack(
          children: [
            // Main content
            _pages[_selectedIndex],
            
            // Dark overlay (chỉ che main content, không che bottom nav và dropdown)
            if (_showMoreDropdown)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _hideMoreDropdown,
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
            
            // More dropdown (nằm trên overlay nhưng dưới bottom navigation)
            if (_showMoreDropdown && _dropdownAnimation != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0.h,
                child: SlideTransition(
                  position: _dropdownAnimation!,
                  child: GestureDetector(
                    onTap: () {}, // Ngăn tap propagate lên parent
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
              ),
          ],
        ),
        bottomNavigationBar: AppBottomNav(
          items: const [
            AppBottomNavItem(
              imageAssetPath: 'assets/icons/learn.png',
              label: 'Học',
            ),
            AppBottomNavItem(
              imageAssetPath: 'assets/icons/reward.png',
              label: 'Nhiệm vụ',
            ),
            AppBottomNavItem(
              imageAssetPath: 'assets/icons/quest.png',
              label: 'Bảng xếp hạng',
            ),
            AppBottomNavItem(
              imageAssetPath: 'assets/icons/feed.png',
              label: 'Bảng tin',
            ),
            AppBottomNavItem(
              imageAssetPath: 'assets/icons/friend.png',
              label: 'Trợ lý',
            ),
            AppBottomNavItem(
              imageAssetPath: 'assets/icons/more.png',
              label: 'Thêm',
            ),
          ],
          showcaseKeys: [
            _learnTabKey,
            _questTabKey,
            _leaderboardTabKey,
            _newFeedTabKey,
            _assistantTabKey,
            _moreTabKey,
          ],
          initialIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
        floatingActionButton: BlocBuilder<FabCubit, bool>(
          builder: (context, isVisible) {
            if (!isVisible) return const SizedBox.shrink();
            return SpeedDial(
              icon: Icons.lightbulb_outline,
              activeIcon: Icons.close,
              backgroundColor: AppColors.beakHighlight,
              children: [
                SpeedDialChild(
                  child: const Icon(Icons.assistant_navigation),
                  backgroundColor: Colors.green,
                  label: 'Điều hướng',
                  onTap: () {
                    context.read<ShowCaseCubit>().resetNavShowCase();
                  },
                ),
                SpeedDialChild(
                  child: const Icon(Icons.book),
                  backgroundColor: Colors.blue,
                  label: 'Bài học',
                  onTap: () {
                    context.read<ShowCaseCubit>().resetLessonShowCase();
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
