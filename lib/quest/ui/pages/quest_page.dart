import 'package:flutter/material.dart';
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
import 'package:vocabu_rex_mobile/home/ui/widgets/dot_loading_indicator.dart';
import '../widgets/daily_quest_card.dart';
import '../widgets/friends_quest_card.dart';
import 'package:vocabu_rex_mobile/theme/widgets/horizontal_carousel.dart';
import 'package:vocabu_rex_mobile/core/interaction_service.dart';

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
    return BlocListener<QuestBloc, QuestState>(
      listener: (context, state) {
        if (state is QuestClaimSuccess) {
          InteractionService.playReward();
          final quest = state.claimedQuest.quest;
          Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (context) => QuestRewardPage(
                questName: quest.name,
                rewardXp: quest.rewardXp,
                rewardGems: quest.rewardGems,
                chestType: quest.chestType ?? ChestType.bronze,
              ),
              fullscreenDialog: true,
            ),
          );
        }
      },
      child: const _QuestPageContent(),
    );
  }
}

class _QuestPageContent extends StatefulWidget {
  const _QuestPageContent();

  @override
  State<_QuestPageContent> createState() => _QuestPageContentState();
}

class _QuestPageContentState extends State<_QuestPageContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
            return const Center(
              child: DotLoadingIndicator(color: _questPurpleLight, size: 16),
            );
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
                  SliverToBoxAdapter(
                    child: _DailyFriendsTabContent(state: state),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Đang tải...'));
        },
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
                SizedBox(height: 20.h),
                Stack(
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

class _DailyFriendsTabContent extends StatelessWidget {
  final QuestLoaded state;

  const _DailyFriendsTabContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                  SizedBox(height: 16.h),

                  // Friends Quests - show first
                  ...[
                    FadeInRight(
                      delay: const Duration(milliseconds: 200),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
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
                          if (state.friendsQuests.isNotEmpty) ...[
                            Icon(
                              Icons.access_time,
                              size: 16.w,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              _formatSectionTimeRemaining(
                                state.friendsQuests.first.endDate,
                              ),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    ),
                    if (state.friendsQuests.isNotEmpty)
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        child: HorizontalCarousel(
                          pages: state.friendsQuests.map((quest) {
                          return Center(
                            child: FriendsQuestCard(
                              userQuest: quest,
                              isClaimingId: state is QuestClaiming
                                  ? (state as QuestClaiming).claimingQuestId
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                      ),
                  ],

                  SizedBox(height: 16.h),

                  // Daily Quests
                  ...[
                    FadeInRight(
                      delay: const Duration(milliseconds: 400),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        child: Row(
                        children: [
                          Text(
                            'Chặng Đường Hằng Ngày',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.bodyText,
                            ),
                          ),
                          Spacer(),
                          if (state.dailyQuests.isNotEmpty) ...[
                            Icon(
                              Icons.access_time,
                              size: 16.w,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              _formatSectionTimeRemaining(
                                state.dailyQuests.first.endDate,
                              ),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    ),
                    if (state.dailyQuests.isNotEmpty)
                      FadeInUp(
                        delay: const Duration(milliseconds: 500),
                        child: Column(
                          children: state.dailyQuests.asMap().entries.map((entry) {
                            final index = entry.key;
                            final quest = entry.value;
                            final isLast = index == state.dailyQuests.length - 1;
                            final isCompleted = quest.isCompleted;
                            final isNext = !isCompleted && (index == 0 || state.dailyQuests[index - 1].isCompleted);
                            final isClaimingId = state is QuestClaiming ? (state as QuestClaiming).claimingQuestId : null;

                            return _buildPathNode(
                              context,
                              quest,
                              isLast,
                              isCompleted,
                              isNext,
                              isClaimingId,
                            );
                          }).toList(),
                        ),
                      ),
                  ],

      ],
    );
  }

  Widget _buildPathNode(
    BuildContext context,
    dynamic quest,
    bool isLast,
    bool isCompleted,
    bool isNext,
    String? isClaimingId,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Vertical Line & Node
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
}
