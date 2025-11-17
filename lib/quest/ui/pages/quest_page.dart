import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/quest_bloc.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/quest_event.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/quest_state.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/quest_chest_bloc.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/quest_chest_event.dart';
import 'package:vocabu_rex_mobile/quest/domain/entities/user_quest_entity.dart';
import 'package:vocabu_rex_mobile/quest/data/services/quest_service.dart';
import 'package:vocabu_rex_mobile/quest/data/datasources/quest_datasource_impl.dart';
import 'package:vocabu_rex_mobile/quest/data/repositories/quest_repository_impl.dart';
import 'package:vocabu_rex_mobile/quest/domain/usecases/get_user_quests_usecase.dart';
import 'package:vocabu_rex_mobile/quest/domain/usecases/get_completed_quests_usecase.dart';
import 'package:vocabu_rex_mobile/quest/domain/usecases/claim_quest_usecase.dart';
import 'package:vocabu_rex_mobile/quest/domain/usecases/get_unlocked_chests_usecase.dart';
import 'package:vocabu_rex_mobile/quest/domain/usecases/open_chest_usecase.dart';
import '../widgets/daily_quest_card.dart';
import '../widgets/friends_quest_card.dart';
import '../widgets/monthly_badge_card.dart';

const Color _questPurpleLight = Color(0xFF9044DF);
const Color _questPurpleDark = Color(0xFF532488);
const Color _questOrange = Color(0xFFF9A800);
const Color _questGrayBackground = Color(0xFFF7F7F7);

class QuestsPage extends StatelessWidget {
  const QuestsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final questService = QuestService();
    final dataSource = QuestDataSourceImpl(questService);
    final repository = QuestRepositoryImpl(questDataSource: dataSource);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => QuestBloc(
            getUserQuestsUseCase: GetUserQuestsUseCase(repository: repository),
            getCompletedQuestsUseCase: GetCompletedQuestsUseCase(repository: repository),
            claimQuestUseCase: ClaimQuestUseCase(repository: repository),
          )..add(GetUserQuestsEvent(activeOnly: false)),
        ),
        BlocProvider(
          create: (context) => QuestChestBloc(
            getUnlockedChestsUseCase: GetUnlockedChestsUseCase(repository: repository),
            openChestUseCase: OpenChestUseCase(repository: repository),
          )..add(GetUnlockedChestsEvent()),
        ),
      ],
      child: const _QuestPageContent(),
    );
  }
}

class _QuestPageContent extends StatelessWidget {
  const _QuestPageContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _questGrayBackground,
        body: Column(
          children: [
            _buildHeader(context),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                children: [
                  _DailyFriendsTab(),
                  _MonthlyBadgeTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<QuestBloc, QuestState>(
      builder: (context, state) {
        int completedDaily = 0;
        int totalDaily = 3;

        if (state is QuestLoaded) {
          completedDaily = state.dailyQuests.where((q) => q.isCompleted).length;
          totalDaily = state.dailyQuests.length;
        }

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_questPurpleLight, _questPurpleDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nhiệm vụ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Hoàn thành $completedDaily/$totalDaily nhiệm vụ hôm nay',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 12.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: totalDaily > 0 ? completedDaily / totalDaily : 0,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(_questOrange),
                    minHeight: 8.h,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        labelColor: _questPurpleDark,
        unselectedLabelColor: Colors.grey,
        indicatorColor: _questPurpleDark,
        indicatorWeight: 3,
        labelStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
        tabs: const [
          Tab(text: 'Hàng ngày & Bạn bè'),
          Tab(text: 'Huy hiệu tháng'),
        ],
      ),
    );
  }
}

class _DailyFriendsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuestBloc, QuestState>(
      builder: (context, state) {
        if (state is QuestLoading) {
          return const Center(child: CircularProgressIndicator());
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
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  
                  // Friends Quests - show first
                  if (state.friendsQuests.isNotEmpty) ...[
                    Padding(
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
                            '3 NGÀY',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...state.friendsQuests.map((quest) => FriendsQuestCard(
                      userQuest: quest,
                      isClaimingId: state is QuestClaiming ? (state as QuestClaiming).claimingQuestId : null,
                    )),
                  ],
                  
                  SizedBox(height: 16.h),
                  
                  // Daily Quests - limit to 3 only
                  if (state.dailyQuests.isNotEmpty) ...[
                    Padding(
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
                          Icon(Icons.access_time, size: 16.w, color: Colors.orange),
                          SizedBox(width: 4.w),
                          Text(
                            '11 TIẾNG',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Only show first 3 daily quests
                    ...state.dailyQuests.take(3).map((quest) => DailyQuestCard(
                      userQuest: quest,
                      isClaimingId: state is QuestClaiming ? (state as QuestClaiming).claimingQuestId : null,
                    )),
                  ],
                  
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          );
        }

        return const Center(child: Text('Đang tải...'));
      },
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

class _MonthlyBadgeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuestBloc, QuestState>(
      builder: (context, state) {
        if (state is QuestLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is QuestError) {
          return _buildErrorView(context, state.message);
        }

        if (state is QuestLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<QuestBloc>().add(RefreshQuestsEvent());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      'Thử thách tháng này',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.bodyText,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 12.h),
                  
                  if (state.monthlyBadgeQuests.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(32.w),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.emoji_events_outlined, size: 64.w, color: Colors.grey),
                            SizedBox(height: 16.h),
                            Text(
                              'Chưa có thử thách nào trong tháng này',
                              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...state.monthlyBadgeQuests.map((quest) => MonthlyBadgeCard(
                      userQuest: quest,
                      isClaimingId: state is QuestClaiming ? (state as QuestClaiming).claimingQuestId : null,
                    )),
                  
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          );
        }

        return const Center(child: Text('Đang tải...'));
      },
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
