import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/quest_bloc.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/quest_event.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/quest_state.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/quest_chest_bloc.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/quest_chest_event.dart';
import 'package:vocabu_rex_mobile/quest/ui/pages/quest_reward_page.dart';
import 'package:vocabu_rex_mobile/quest/domain/enums/quest_enums.dart';
import 'package:vocabu_rex_mobile/quest/domain/entities/user_quest_entity.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/dot_loading_indicator.dart';
import '../widgets/daily_quest_card.dart';
import '../widgets/friends_quest_card.dart';
import 'package:vocabu_rex_mobile/theme/widgets/horizontal_carousel.dart';
import 'package:vocabu_rex_mobile/core/interaction_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import 'package:vocabu_rex_mobile/currency/ui/blocs/currency_bloc.dart';
import 'package:vocabu_rex_mobile/theme/widgets/static_space_background.dart';

const Color _questPurpleLight = Color(0xFF9044DF);
const Color _questPurpleDark = Color(0xFF532488);
const Color _questOrange = Color(0xFFF9A800);

class QuestsPage extends StatefulWidget {
  const QuestsPage({super.key});

  @override
  State<QuestsPage> createState() => _QuestsPageState();
}

class _QuestsPageState extends State<QuestsPage> {
  @override
  void initState() {
    super.initState();
    // Initialize quest data when page loads
    context.read<QuestBloc>().add(GetUserQuestsEvent(activeOnly: false));
    context.read<QuestChestBloc>().add(GetUnlockedChestsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return const _QuestPageContent();
  }
}

class _QuestPageContent extends StatefulWidget {
  const _QuestPageContent();

  @override
  State<_QuestPageContent> createState() => _QuestPageContentState();
}

class _QuestPageContentState extends State<_QuestPageContent> with TickerProviderStateMixin {
  final GlobalKey _gemKey = GlobalKey();
  final GlobalKey _coinKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return BlocListener<QuestBloc, QuestState>(
      listener: (context, state) {
        if (state is QuestClaimSuccess) {
          InteractionService.playReward();
          final quest = state.claimedQuest.quest;
          
          // Fire particles
          if (quest.rewardGems > 0) {
            _showParticles(isGem: true, count: math.min(10, quest.rewardGems));
          }
          if (quest.rewardXp > 0 || (quest.rewardGems == 0)) {
             // Treat fallback as coins
            _showParticles(isGem: false, count: 10);
          }
          
          // Fetch balance after particles reach the target
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (context.mounted) {
              context.read<CurrencyBloc>().add(GetCurrencyBalanceEvent(''));
            }
          });
        }
      },
      child: StaticSpaceBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: BlocBuilder<QuestBloc, QuestState>(
        builder: (context, state) {
          int completedDaily = 0;
          int totalDaily = 3;

          if (state is QuestLoaded) {
            completedDaily = state.dailyQuests.where((q) => q.isCompleted).length;
            totalDaily = state.dailyQuests.isNotEmpty ? state.dailyQuests.length : 3;
          }

          final double progress = totalDaily > 0 ? completedDaily / totalDaily : 0;
          final bool isAllCompleted = progress >= 1.0;

          if (state is QuestLoading) {
            return _buildSkeleton(AppPreferences().isDarkMode);
          }

          if (state is QuestError) {
            return _buildErrorView(context, state.message);
          }

          if (state is QuestLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<QuestBloc>().add(RefreshQuestsEvent());
                context.read<QuestChestBloc>().add(RefreshChestsEvent());
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  _buildSliverHeader(context, completedDaily, totalDaily, progress, isAllCompleted),
                  if (state.friendsQuests.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _buildFriendsQuests(state),
                    ),
                  _buildDailyQuestsHeader(state),
                  _buildDailyQuestsSliver(state),
                ],
              ),
            );
          }

          return const Center(child: Text('Đang tải...'));
        },
      ),
    ),
      ),
    );
  }


  void _showParticles({required bool isGem, required int count}) {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    // Start somewhere in the middle-bottom
    final startOffset = Offset(renderBox.size.width / 2, renderBox.size.height * 0.7);
    
    final targetKey = isGem ? _gemKey : _coinKey;
    final targetContext = targetKey.currentContext;
    if (targetContext == null) return;
    
    final targetRenderBox = targetContext.findRenderObject() as RenderBox?;
    if (targetRenderBox == null) return;
    
    final targetOffset = targetRenderBox.localToGlobal(
      Offset(targetRenderBox.size.width / 2, targetRenderBox.size.height / 2),
    );

    final random = math.Random();
    
    for (int i = 0; i < count; i++) {
      // Create random control point for bezier curve
      final controlPoint = Offset(
        startOffset.dx + (random.nextDouble() - 0.5) * 200,
        startOffset.dy - 100 - random.nextDouble() * 100,
      );
      
      late OverlayEntry entry;
      final controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 600 + random.nextInt(400)),
      );
      
      entry = OverlayEntry(
        builder: (context) {
          return AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              final t = Curves.easeOut.transform(controller.value);
              // Quadratic bezier
              final currentX = math.pow(1 - t, 2) * startOffset.dx +
                               2 * (1 - t) * t * controlPoint.dx +
                               math.pow(t, 2) * targetOffset.dx;
              final currentY = math.pow(1 - t, 2) * startOffset.dy +
                               2 * (1 - t) * t * controlPoint.dy +
                               math.pow(t, 2) * targetOffset.dy;
              
              return Positioned(
                left: currentX - 15, // half of icon size
                top: currentY - 15,
                child: Transform.scale(
                  scale: controller.value < 0.2 
                      ? controller.value * 5 
                      : (1.0 - (controller.value > 0.8 ? (controller.value - 0.8) * 5 : 0)),
                  child: Image.asset(
                    isGem ? 'assets/icons/gem.png' : 'assets/icons/coin.png',
                    width: 30,
                    height: 30,
                  ),
                ),
              );
            },
          );
        },
      );
      
      overlay.insert(entry);
      
      // Delay start slightly for each particle
      Future.delayed(Duration(milliseconds: i * 50), () {
        controller.forward().then((_) {
          entry.remove();
          controller.dispose();
        });
      });
    }
  }

  Widget _buildSkeleton(bool isDark) {
    final baseColor = isDark ? Colors.white12 : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.white24 : Colors.grey[100]!;
    final itemColor = Colors.white;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 360.h,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: isDark ? Colors.grey[900] : Colors.grey[300],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: itemColor,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: itemColor),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Container(
                          height: 80.h,
                          decoration: BoxDecoration(
                            color: itemColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context, int completedDaily, int totalDaily, double progress, bool isAllCompleted) {
    return SliverAppBar(
      expandedHeight: 360.h,
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: isAllCompleted ? const Color(0xFFFF9800) : _questPurpleDark,
      leadingWidth: 120.w,
      leading: BlocBuilder<CurrencyBloc, CurrencyState>(
        builder: (context, currencyState) {
          int gems = 0;
          if (currencyState is CurrencyLoaded) {
            gems = currencyState.balance.gems;
          }
          return Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 16.w),
            child: _buildCurrencyBadge('assets/icons/gem.png', gems, badgeKey: _gemKey),
          );
        },
      ),
      actions: [
        BlocBuilder<CurrencyBloc, CurrencyState>(
          builder: (context, currencyState) {
            int coins = 0;
            if (currencyState is CurrencyLoaded) {
              coins = currencyState.balance.coins;
            }
            return Container(
              alignment: Alignment.centerRight,
              child: _buildCurrencyBadge('assets/icons/coin.png', coins, badgeKey: _coinKey),
            );
          },
        ),
        SizedBox(width: 16.w),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: EdgeInsets.only(bottom: 16.h),
        title: Text(
          'TRẠM SĂN THƯỞNG',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isAllCompleted 
                  ? [const Color(0xFFFFC107), const Color(0xFFFF9800)]
                  : [_questPurpleLight, _questPurpleDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: kToolbarHeight),
                ZoomIn(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                    // Circular progress
                    SizedBox(
                      width: 140.w,
                      height: 140.w,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: progress),
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return CircularProgressIndicator(
                            value: value,
                            strokeWidth: 12.w,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isAllCompleted ? Colors.white : AppColors.macaw,
                            ),
                            strokeCap: StrokeCap.round,
                          );
                        },
                      ),
                    ),
                    // Mega Chest
                    WidgetAnimator(
                      isAllCompleted: isAllCompleted,
                      child: Image.asset(
                        isAllCompleted 
                            ? 'assets/icons/chest_legendary_close.png' 
                            : 'assets/icons/chest_gold_close.png',
                        width: 80.w,
                        height: 80.w,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.inventory_2,
                            color: isAllCompleted ? Colors.white : Colors.amber,
                            size: 80.w,
                          );
                        },
                      ),
                    ),
                  ],
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  isAllCompleted 
                      ? 'ĐÃ HOÀN THÀNH TẤT CẢ!' 
                      : 'Hoàn thành $completedDaily/$totalDaily nhiệm vụ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  isAllCompleted
                      ? 'Chờ đón phần thưởng lớn ngày mai nhé!'
                      : 'Cố lên, phần thưởng lớn đang chờ bạn!',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 40.h), // Space for the pinned title
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64.w, color: Colors.grey),
          SizedBox(height: 16.h),
          Text(
            'Lỗi: $message',
            style: TextStyle(fontSize: 16.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              context.read<QuestBloc>().add(RefreshQuestsEvent());
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }


  Widget _buildFriendsQuests(QuestLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        FadeInRight(
          delay: const Duration(milliseconds: 200),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Text(
                  'Nhiệm vụ bạn bè',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.bodyText,
                  ),
                ),
                Spacer(),
                Icon(Icons.access_time, size: 16.w, color: Colors.orange),
                SizedBox(width: 4.w),
                Text(
                  _formatSectionTimeRemaining(state.friendsQuests.first.endDate),
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ],
            ),
          ),
        ),
        FadeInUp(
          delay: const Duration(milliseconds: 300),
          child: HorizontalCarousel(
            pages: state.friendsQuests.map((quest) {
              return Center(
                child: FriendsQuestCard(
                  userQuest: quest,
                  isClaimingId: state is QuestClaiming ? (state as QuestClaiming).claimingQuestId : null,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyQuestsHeader(QuestLoaded state) {
    return SliverToBoxAdapter(
      child: FadeInRight(
        delay: const Duration(milliseconds: 400),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Text(
                'Nhiệm vụ hằng ngày',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.bodyText,
                ),
              ),
              Spacer(),
              if (state.dailyQuests.isNotEmpty) ...[
                Icon(Icons.access_time, size: 16.w, color: Colors.orange),
                SizedBox(width: 4.w),
                Text(
                  _formatSectionTimeRemaining(state.dailyQuests.first.endDate),
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyQuestsSliver(QuestLoaded state) {
    if (state.dailyQuests.isEmpty) {
      return SliverToBoxAdapter(child: SizedBox());
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final quest = state.dailyQuests[index];
          final isClaimingId = state is QuestClaiming ? (state as QuestClaiming).claimingQuestId : null;
          
          return FadeInLeft(
            delay: Duration(milliseconds: 400 + index * 100),
            child: _buildPathNode(state, quest, index, state.dailyQuests.length, isClaimingId),
          );
        },
        childCount: state.dailyQuests.length,
      ),
    );
  }

  Widget _buildPathNode(QuestLoaded state, UserQuestEntity quest, int index, int total, String? isClaimingId) {
    final isCompleted = quest.isCompleted;
    final isNext = !isCompleted && (index == 0 || state.dailyQuests[index - 1].isCompleted);
    final isLast = index == total - 1;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timeline line & node
            SizedBox(
              width: 40.w,
              child: Column(
                children: [
                  Container(
                    width: 28.w,
                    height: 28.w,
                    margin: EdgeInsets.only(top: 24.h),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? AppColors.featherGreen : (isNext ? AppColors.bee : AppColors.swan),
                      border: Border.all(color: AppColors.snow, width: 4),
                      boxShadow: isNext 
                          ? [BoxShadow(color: AppColors.bee.withValues(alpha: 0.5), blurRadius: 12, spreadRadius: 4)]
                          : [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
                    ),
                    child: isCompleted
                        ? Icon(Icons.check, size: 16.w, color: Colors.white)
                        : (isNext ? Icon(Icons.star, size: 14.w, color: Colors.white) : null),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 6.w,
                        margin: EdgeInsets.only(top: 8.h),
                        decoration: BoxDecoration(
                          color: isCompleted ? AppColors.featherGreen : AppColors.swan,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            // Card Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: 24.h),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.snow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isCompleted ? AppColors.featherGreen : (isNext ? AppColors.bee : AppColors.swan),
                      width: isNext ? 3 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isNext ? AppColors.bee : Colors.black).withValues(alpha: isNext ? 0.2 : 0.05),
                        blurRadius: isNext ? 16 : 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: DailyQuestCard(
                    userQuest: quest,
                    isClaimingId: isClaimingId,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSectionTimeRemaining(DateTime endDate) {
    final now = DateTime.now();
    final diff = endDate.difference(now);

    if (diff.isNegative) return 'Đã hết hạn';

    if (diff.inDays > 0) {
      final hours = diff.inHours % 24;
      if (hours > 0) {
        return '${diff.inDays} NGÀY ${hours}H';
      }
      return '${diff.inDays} NGÀY';
    } else if (diff.inHours > 0) {
      final minutes = diff.inMinutes % 60;
      return '${diff.inHours} TIẾNG ${minutes}P';
    } else {
      return '${diff.inMinutes} PHÚT';
    }
  }

  Widget _buildCurrencyBadge(String iconPath, int value, {Key? badgeKey}) {
    return Container(
      key: badgeKey,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(iconPath, width: 16.w, height: 16.w),
          SizedBox(width: 4.w),
          Text(
            '$value',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class WidgetAnimator extends StatelessWidget {
  final bool isAllCompleted;
  final Widget child;

  const WidgetAnimator({super.key, required this.isAllCompleted, required this.child});

  @override
  Widget build(BuildContext context) {
    if (isAllCompleted) {
      return Pulse(infinite: true, child: child);
    }
    return child;
  }
}

