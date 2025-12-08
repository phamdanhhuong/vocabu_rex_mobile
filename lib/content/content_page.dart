import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:vocabu_rex_mobile/assistant/ui/pages/assistant_page.dart';
import 'package:vocabu_rex_mobile/feed/ui/pages/feed_page.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/fab_cubit.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/show_case_cubit.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/quest/ui/pages/quest_page.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:vocabu_rex_mobile/theme/widgets/navigations/app_bottom_navigation.dart';
import 'package:vocabu_rex_mobile/home/ui/pages/home_page.dart';
import 'package:vocabu_rex_mobile/leaderboard/ui/pages/leaderboard_page.dart';
import 'package:vocabu_rex_mobile/more/ui/pages/more_page.dart';
import 'package:vocabu_rex_mobile/profile/ui/pages/profile_page.dart';
import 'package:vocabu_rex_mobile/pronunciation/ui/pages/pronunciation_page.dart';
import 'package:vocabu_rex_mobile/more/ui/pages/video_call_page.dart';
import 'package:vocabu_rex_mobile/more/ui/pages/practice_center_page.dart';
import 'package:home_widget/home_widget.dart';

// Các key mới để lưu dữ liệu
const String _kStreakCountKey = 'streak_count';
const String _kMessageKey = 'widget_message';
const String _kTrexImageKey =
    'trex_image'; // Ví dụ: 'img_trex_normal' hoặc 'img_trex_sad'
const String _kBackgroundColorKey =
    'background_color'; // Ví dụ: '#F778BA' (hồng) hoặc '#00B0FF' (xanh)

class ContentPage extends StatefulWidget {
  const ContentPage({Key? key}) : super(key: key);

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage>
    with TickerProviderStateMixin {
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
    const FeedPage(),
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

    // Đóng dropdown nếu đang mở
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
    _dropdownAnimationController = AnimationController(
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

  int _streakCount = 2683; // Giá trị ví dụ
  String _currentMessage = "Let's practice!";
  String _currentTrexImage = "img_trex_normal"; // Tên file drawable
  String _currentBackgroundColor = "#F778BA"; // Màu hồng Duolingo

  // Tải dữ liệu ban đầu từ widget (nếu có)
  Future<void> _loadWidgetData() async {
    final savedStreak = await HomeWidget.getWidgetData<String>(
      _kStreakCountKey,
      defaultValue: _streakCount.toString(),
    );
    final savedMessage = await HomeWidget.getWidgetData<String>(
      _kMessageKey,
      defaultValue: _currentMessage,
    );
    final savedTrexImage = await HomeWidget.getWidgetData<String>(
      _kTrexImageKey,
      defaultValue: _currentTrexImage,
    );
    final savedBgColor = await HomeWidget.getWidgetData<String>(
      _kBackgroundColorKey,
      defaultValue: _currentBackgroundColor,
    );

    setState(() {
      _streakCount = int.parse(savedStreak!);
      _currentMessage = savedMessage!;
      _currentTrexImage = savedTrexImage!;
      _currentBackgroundColor = savedBgColor!;
    });
  }

  Future<void> _updateHomeWidget() async {
    await HomeWidget.saveWidgetData<String>(
      _kStreakCountKey,
      _streakCount.toString(),
    );
    await HomeWidget.saveWidgetData<String>(_kMessageKey, _currentMessage);
    await HomeWidget.saveWidgetData<String>(_kTrexImageKey, _currentTrexImage);
    await HomeWidget.saveWidgetData<String>(
      _kBackgroundColorKey,
      _currentBackgroundColor,
    );

    await HomeWidget.updateWidget(
      name: 'HomeWidgetProvider',
      androidName: 'HomeWidgetProvider',
    );
  }

  void _incrementStreak() {
    setState(() {
      _streakCount++;
      _currentMessage = "Tuyệt vời! Tiếp tục nào!";
      _currentTrexImage = "img_trex_normal"; // Thay đổi trạng thái T-Rex
      _currentBackgroundColor = "#F778BA"; // Màu hồng
    });
    _updateHomeWidget();
  }

  void _simulateBrokenStreak() {
    setState(() {
      _streakCount = 0; // Đặt lại streak
      _currentMessage = "Streak đã bị mất! Hãy bắt đầu lại!";
      _currentTrexImage = "img_trex_sad"; // T-Rex buồn
      _currentBackgroundColor =
          "#4CAF50"; // Màu xanh (như Duolingo khi streak sắp hỏng)
    });
    _updateHomeWidget();
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
    _loadWidgetData();
  }

  @override
  void dispose() {
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
            // Main content với fade transition khi chuyển trang
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: KeyedSubtree(
                key: ValueKey<int>(_selectedIndex),
                child: _pages[_selectedIndex],
              ),
            ),

            // Dark overlay (chỉ che main content, không che bottom nav và dropdown)
            if (_showMoreDropdown)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _hideMoreDropdown,
                  child: Container(color: Colors.black.withOpacity(0.5)),
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
                SpeedDialChild(
                  child: const Icon(Icons.book),
                  backgroundColor: Colors.blue,
                  label: 'tăng',
                  onTap: () {
                    _incrementStreak();
                  },
                ),
                SpeedDialChild(
                  child: const Icon(Icons.book),
                  backgroundColor: Colors.blue,
                  label: 'break',
                  onTap: () {
                    _simulateBrokenStreak();
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
