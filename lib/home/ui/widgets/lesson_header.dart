import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/show_case_cubit.dart';
import '../../../theme/colors.dart'; // Đảm bảo đường dẫn này chính xác
import 'lesson_header_tokens.dart';
import 'package:vocabu_rex_mobile/energy/ui/widgets/enegy_dropdown.dart';
import 'package:vocabu_rex_mobile/energy/ui/widgets/energy_dropdown_tokens.dart';
import 'package:vocabu_rex_mobile/theme/widgets/speech_bubbles/speech_bubble.dart';
import 'package:vocabu_rex_mobile/streak/ui/widgets/streak_view.dart';
import 'package:vocabu_rex_mobile/core/slide_up_route.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/course_progress_view.dart';
import 'package:vocabu_rex_mobile/energy/ui/blocs/energy_bloc.dart';
import 'package:vocabu_rex_mobile/currency/ui/blocs/currency_bloc.dart';

/// Thanh trạng thái (stats bar) hiển thị ở đầu màn hình bài học.
///
/// Bao gồm Cờ, Streak, Gems, Coins, và Hearts.
class LessonHeader extends StatefulWidget {
  /// Đường dẫn đến ảnh lá cờ.
  final String flagAssetPath = 'assets/flags/english.png';
  // SỬA ĐỔI: Thêm đường dẫn cho các icon PNG
  final String streakIconPath = 'assets/icons/streak.png';
  final String gemIconPath = 'assets/icons/gem.png';
  final String coinIconPath = 'assets/icons/coin.png';
  final String heartIconPath = 'assets/icons/heart.png';

  /// Số hiển thị bên cạnh cờ (ví dụ: cấp độ).
  final int courseProgress;
  final int streakCount;
  final int gemCount;
  final int coinCount; // Thêm loại tiền tệ thứ 2 theo yêu cầu
  final int heartCount;

  const LessonHeader({
    Key? key,
    // required this.flagAssetPath,
    // SỬA ĐỔI: Thêm vào constructor
    required this.courseProgress,
    required this.streakCount,
    required this.gemCount,
    required this.coinCount,
    required this.heartCount,
  }) : super(key: key);

  @override
  State<LessonHeader> createState() => _LessonHeaderState();
}

class _LessonHeaderState extends State<LessonHeader> {
  // 1. KHAI BÁO KEY CHO TỪNG STAT ITEM
  final GlobalKey _flagKey = GlobalKey(); // For showcase
  final GlobalKey _flagPositionKey = GlobalKey(); // For overlay position
  final GlobalKey _streakKey = GlobalKey();
  final GlobalKey _gemKey = GlobalKey();
  final GlobalKey _coinKey = GlobalKey();

  final GlobalKey _heartKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  Timer? _hideTimer;
  GlobalKey<_HeartsOverlayState>? _heartsOverlayKey;
  
  // Course Progress overlay
  OverlayEntry? _courseProgressOverlayEntry;
  Timer? _courseProgressHideTimer;
  GlobalKey<_CourseProgressOverlayState>? _courseProgressOverlayKey;
  void _showOverlay() {
    // Đóng course progress overlay nếu đang mở
    if (_courseProgressOverlayEntry != null) {
      _removeCourseProgressOverlay();
    }
    
    _hideTimer?.cancel();
    if (_overlayEntry != null) return;

    final renderBox =
        _heartKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final overlay = Overlay.of(context);

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    // Get the height of the AppBar/Header to position overlay right below it
    final appBarRenderBox = context.findRenderObject() as RenderBox?;
    final appBarHeight = appBarRenderBox != null 
        ? appBarRenderBox.localToGlobal(Offset.zero).dy + appBarRenderBox.size.height
        : MediaQuery.of(context).padding.top + 56.0; // fallback
    
    _heartsOverlayKey = GlobalKey<_HeartsOverlayState>();
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Dark overlay background - only covers area below the header
            Positioned(
              left: 0,
              right: 0,
              top: appBarHeight,
              bottom: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  // fire-and-forget; removal will animate
                  _removeOverlay();
                },
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),
            ),
            // Clip the HeartsView so it doesn't overlap the header during animation
            Positioned(
              left: 0,
              right: 0,
              top: appBarHeight,
              bottom: 0,
              child: ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Material(
                    color: Colors.transparent,
                    child: BlocListener<EnergyBloc, EnergyState>(
                      listener: (context, state) {
                        print('🔍 EnergyBloc state changed in listener: ${state.runtimeType}');
                        if (state is EnergyBuySuccess) {
                          print('🎯 Energy purchase successful in overlay!');
                          // Refresh currency balance
                          print('💰 Dispatching GetCurrencyBalanceEvent...');
                          context.read<CurrencyBloc>().add(GetCurrencyBalanceEvent(''));
                          // Refresh energy status
                          print('⚡ Dispatching GetEnergyStatusEvent...');
                          context.read<EnergyBloc>().add(GetEnergyStatusEvent());
                        }
                      },
                      child: _HeartsOverlay(
                        key: _heartsOverlayKey,
                        animateFromTop: true,
                        child: BlocBuilder<EnergyBloc, EnergyState>(
                          builder: (context, energyState) {
                            int currentHearts = widget.heartCount;
                            if (energyState is EnergyLoaded) {
                              currentHearts = energyState.response.currentEnergy;
                            }
                            
                            return BlocBuilder<CurrencyBloc, CurrencyState>(
                              builder: (context, currencyState) {
                                int gems = widget.gemCount;
                                int coins = widget.coinCount;
                                if (currencyState is CurrencyLoaded) {
                                  gems = currencyState.balance.gems;
                                  coins = currencyState.balance.coins;
                                }
                                
                                return HeartsView(
                                  currentHearts: currentHearts,
                                  maxHearts: EnergyDropdownTokens.defaultMaxHearts,
                                  timeUntilNextRecharge: '5 tiếng',
                                  gemCostPerEnergy:
                                      EnergyDropdownTokens.defaultGemCostPerEnergy,
                                  coinCostPerEnergy:
                                      EnergyDropdownTokens.defaultCoinCostPerEnergy,
                                  gemsBalance: gems,
                                  coinsBalance: coins,
                                  useSpeechBubble: false,
                                  onClose: () {
                                    _removeOverlay();
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  Future<void> _removeOverlay() async {
    _hideTimer?.cancel();
    if (_overlayEntry == null) return;
    try {
      final state = _heartsOverlayKey?.currentState;
      if (state != null) {
        // play reverse animation before removing
        await state.close();
      }
    } catch (_) {
      // ignore animation errors and still remove
    }
    _overlayEntry?.remove();
    _overlayEntry = null;
    _heartsOverlayKey = null;
  }

  // Course Progress Overlay methods
  void _showCourseProgressOverlay() {
    print('_showCourseProgressOverlay called');
    
    // Đóng hearts overlay nếu đang mở
    if (_overlayEntry != null) {
      _removeOverlay();
    }
    
    _courseProgressHideTimer?.cancel();
    if (_courseProgressOverlayEntry != null) {
      print('Overlay already exists');
      return;
    }

    final renderBox = _flagPositionKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      print('RenderBox is null - flag key context not found');
      return;
    }
    print('RenderBox found, creating overlay');
    final overlay = Overlay.of(context);

    final appBarRenderBox = context.findRenderObject() as RenderBox?;
    final appBarHeight = appBarRenderBox != null 
        ? appBarRenderBox.localToGlobal(Offset.zero).dy + appBarRenderBox.size.height
        : MediaQuery.of(context).padding.top + 56.0;
    
    _courseProgressOverlayKey = GlobalKey<_CourseProgressOverlayState>();
    _courseProgressOverlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Dark overlay background
            Positioned(
              left: 0,
              right: 0,
              top: appBarHeight,
              bottom: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _removeCourseProgressOverlay();
                },
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),
            ),
            // Course Progress View
            Positioned(
              left: 0,
              right: 0,
              top: appBarHeight,
              bottom: 0,
              child: ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Material(
                    color: Colors.transparent,
                    child: _CourseProgressOverlay(
                      key: _courseProgressOverlayKey,
                      animateFromTop: true,
                      child: CourseProgressView(
                        currentLevel: widget.courseProgress,
                        courseName: 'Tiếng Anh',
                        onClose: () {
                          _removeCourseProgressOverlay();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_courseProgressOverlayEntry!);
  }

  Future<void> _removeCourseProgressOverlay() async {
    _courseProgressHideTimer?.cancel();
    if (_courseProgressOverlayEntry == null) return;
    try {
      final state = _courseProgressOverlayKey?.currentState;
      if (state != null) {
        await state.close();
      }
    } catch (_) {
      // ignore animation errors
    }
    _courseProgressOverlayEntry?.remove();
    _courseProgressOverlayEntry = null;
    _courseProgressOverlayKey = null;
  }

  // removed hover auto-hide; overlay is tap-persistent until outside tap

  @override
  void dispose() {
    _hideTimer?.cancel();
    _removeOverlay();
    _courseProgressHideTimer?.cancel();
    _removeCourseProgressOverlay();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    context.read<ShowCaseCubit>().registerKey('flag', _flagKey);
    context.read<ShowCaseCubit>().registerKey('streak', _streakKey);
    context.read<ShowCaseCubit>().registerKey('gem', _gemKey);
    context.read<ShowCaseCubit>().registerKey('coin', _coinKey);
    context.read<ShowCaseCubit>().registerKey('heart', _heartKey);

    return Padding(
      padding: const EdgeInsets.only(
        left: LessonHeaderTokens.horizontalPadding,
        right: LessonHeaderTokens.horizontalPadding,
        top: LessonHeaderTokens.verticalPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. FLAG (Cấp độ khóa học)
          GestureDetector(
            onTap: () {
              print('Flag tapped!');
              if (_courseProgressOverlayEntry == null) {
                _showCourseProgressOverlay();
              } else {
                _removeCourseProgressOverlay();
              }
            },
            child: Showcase(
              key: _flagKey,
              description: 'Đây là tiến độ khóa học hiện tại của bạn.',
              child: Container(
                key: _flagPositionKey,
                child: _StatItem(
                  icon: Image.asset(
                    widget.flagAssetPath,
                    width: LessonHeaderTokens.flagSize,
                    height: LessonHeaderTokens.flagSize,
                  ),
                  value: widget.courseProgress.toString(),
                  color: AppColors.bodyText,
                ),
              ),
            ),
          ),

          // 2. STREAK (Chuỗi ngày học)
          Showcase(
            key: _streakKey,
            description:
                'Giữ chuỗi ngày học để nhận phần thưởng! Nhấn vào đây để xem chi tiết.',
            child: GestureDetector(
              onTap: () {
                Navigator.of(
                  context,
                ).push(SlideUpPageRoute(builder: (_) => const StreakView()));
              },
              child: _StatItem(
                icon: Image.asset(
                  widget.streakIconPath,
                  width: LessonHeaderTokens.iconSize,
                  height: LessonHeaderTokens.iconSize,
                ),
                value: widget.streakCount.toString(),
                color: AppColors.hare,
              ),
            ),
          ),

          // 3. GEM (Đá quý)
          Showcase(
            key: _gemKey,
            description:
                'Đá quý là đơn vị tiền tệ cao cấp dùng để mua vật phẩm đặc biệt.',
            child: BlocBuilder<CurrencyBloc, CurrencyState>(
              builder: (context, currencyState) {
                int gems = widget.gemCount;
                if (currencyState is CurrencyLoaded) {
                  gems = currencyState.balance.gems;
                }
                return _StatItem(
                  icon: Image.asset(
                    widget.gemIconPath,
                    width: LessonHeaderTokens.iconSize,
                    height: LessonHeaderTokens.iconSize,
                  ),
                  value: gems.toString(),
                  color: AppColors.macaw,
                );
              },
            ),
          ),

          // 4. COIN (Tiền xu)
          Showcase(
            key: _coinKey,
            description: 'Tiền xu là đơn vị tiền tệ chính dùng trong cửa hàng.',
            child: BlocBuilder<CurrencyBloc, CurrencyState>(
              builder: (context, currencyState) {
                int coins = widget.coinCount;
                if (currencyState is CurrencyLoaded) {
                  coins = currencyState.balance.coins;
                }
                return _StatItem(
                  icon: Image.asset(
                    widget.coinIconPath,
                    width: LessonHeaderTokens.iconSize,
                    height: LessonHeaderTokens.iconSize,
                  ),
                  value: coins.toString(),
                  color: AppColors.bee,
                );
              },
            ),
          ),

          // 5. HEART (Năng lượng)
          Showcase(
            key: _heartKey, // Sử dụng lại key hiện có
            description:
                'Mỗi bài học tốn một Trái tim. Trái tim sẽ tự nạp lại theo thời gian. Nhấn vào để nạp nhanh!',
            targetShapeBorder:
                const CircleBorder(), // Giả sử biểu tượng trái tim là hình tròn
            child: GestureDetector(
              key: _heartKey, // Key để định vị overlay
              onTap: () {
                if (_overlayEntry == null) {
                  _showOverlay();
                } else {
                  _removeOverlay();
                }
              },
              child: BlocBuilder<EnergyBloc, EnergyState>(
                builder: (context, energyState) {
                  int hearts = widget.heartCount;
                  if (energyState is EnergyLoaded) {
                    hearts = energyState.response.currentEnergy;
                  }
                  return _StatItem(
                    icon: Image.asset(
                      widget.heartIconPath,
                      width: LessonHeaderTokens.iconSize,
                      height: LessonHeaderTokens.iconSize,
                    ),
                    value: hearts.toString(),
                    color: AppColors.cardinal,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Một widget con riêng tư để hiển thị Icon + Giá trị
class _StatItem extends StatelessWidget {
  final Widget icon;
  final String value;
  final Color color;

  const _StatItem({
    Key? key,
    required this.icon,
    required this.value,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Co lại vừa đủ nội dung
      children: [
        icon,
        const SizedBox(width: LessonHeaderTokens.iconTextSpacing),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: LessonHeaderTokens.valueFontSize,
            fontWeight: FontWeight.bold,
            fontFamily:
                LessonHeaderTokens.valueFontFamily, // Giả sử bạn có font này
          ),
        ),
      ],
    );
  }
}

/// Internal overlay widget that runs a slide-down animation on appearing.
class _HeartsOverlay extends StatefulWidget {
  final Widget child;
  final bool animateFromTop;

  const _HeartsOverlay({
    Key? key,
    required this.child,
    this.animateFromTop = true,
  }) : super(key: key);

  @override
  State<_HeartsOverlay> createState() => _HeartsOverlayState();
}

class _HeartsOverlayState extends State<_HeartsOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _offsetAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _offsetAnim = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    // start the animation
    _ctrl.forward();
  }

  /// Play reverse animation and complete when done.
  Future<void> close() async {
    if (mounted) {
      await _ctrl.reverse();
    } else {
      // if not mounted, nothing to do
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnim,
      child: widget.child,
    );
  }
}

/// Overlay widget for course progress with slide-down animation
class _CourseProgressOverlay extends StatefulWidget {
  final Widget child;
  final bool animateFromTop;

  const _CourseProgressOverlay({
    Key? key,
    required this.child,
    this.animateFromTop = true,
  }) : super(key: key);

  @override
  State<_CourseProgressOverlay> createState() => _CourseProgressOverlayState();
}

class _CourseProgressOverlayState extends State<_CourseProgressOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _offsetAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _offsetAnim = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  Future<void> close() async {
    if (mounted) {
      await _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnim,
      child: widget.child,
    );
  }
}
