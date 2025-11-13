import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:vocabu_rex_mobile/assistant/ui/pages/assistant_page.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/show_case_cubit.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/quest/ui/pages/quest_page.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
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
  final GlobalKey _learnTabKey = GlobalKey();
  final GlobalKey _questTabKey = GlobalKey();
  final GlobalKey _leaderboardTabKey = GlobalKey();
  final GlobalKey _newFeedTabKey = GlobalKey();
  final GlobalKey _assistantTabKey = GlobalKey();
  final GlobalKey _moreTabKey = GlobalKey();

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
    // TODO: implement dispose
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
        body: _pages[_selectedIndex],
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
        floatingActionButton: SpeedDial(
          icon: Icons.lightbulb_outline, // Icon khi đóng
          activeIcon: Icons.close, // Icon khi mở
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
        ),
      ),
    );
    //BlocListener<ShowCaseCubit, ShowcaseState>(
    //   listenWhen: (previous, current) {
    //     return previous.hasSeenNavBarShowcase != current.hasSeenNavBarShowcase;
    //   },
    //   listener: (context, state) {
    //     // 💡 HÀNH ĐỘNG CỦA CHÚNG TA ĐẶT Ở ĐÂY
    //     final cubit = context.read<ShowCaseCubit>();
    //     if (!state.hasSeenNavBarShowcase) {
    //       WidgetsBinding.instance.addPostFrameCallback((_) {
    //         final flagKey = cubit.getKey('flag');
    //         final streakKey = cubit.getKey('streak');
    //         final gemKey = cubit.getKey('gem');
    //         final coinKey = cubit.getKey('coin');
    //         final heartKey = cubit.getKey('heart');
    //         // Khởi động chuỗi hướng dẫn
    //         ShowcaseView.get().startShowCase([
    //           _learnTabKey,
    //           _questTabKey,
    //           _leaderboardTabKey,
    //           _newFeedTabKey,
    //           _assistantTabKey,
    //           _moreTabKey,
    //           flagKey!,
    //           streakKey!,
    //           gemKey!,
    //           coinKey!,
    //           heartKey!,
    //         ]);
    //       });
    //       context.read<ShowCaseCubit>().markNavBarShowcaseSeen();
    //     }
    //   },
    //   child:
    // );
  }
}
