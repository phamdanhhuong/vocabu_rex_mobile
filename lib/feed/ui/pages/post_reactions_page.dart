import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/feed/ui/blocs/reaction_bloc.dart';
import 'package:vocabu_rex_mobile/feed/ui/blocs/reaction_event.dart';
import 'package:vocabu_rex_mobile/feed/ui/blocs/reaction_state.dart';
import 'package:vocabu_rex_mobile/feed/data/datasources/feed_datasource_impl.dart';
import 'package:vocabu_rex_mobile/feed/data/repositories/feed_repository_impl.dart';
import 'package:vocabu_rex_mobile/feed/domain/usecases/get_post_reactions_usecase.dart';
import 'package:vocabu_rex_mobile/feed/domain/enums/feed_enums.dart';
import 'package:vocabu_rex_mobile/feed/domain/entities/feed_reaction_entity.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class PostReactionsPage extends StatelessWidget {
  final String postId;
  final List<Map<String, dynamic>> reactionSummary;

  const PostReactionsPage({
    Key? key,
    required this.postId,
    required this.reactionSummary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataSource = FeedDataSourceImpl();
    final repository = FeedRepositoryImpl(dataSource);

    return BlocProvider(
      create: (context) => ReactionBloc(
        getPostReactionsUseCase: GetPostReactionsUseCase(repository),
      )..add(LoadPostReactions(postId: postId)),
      child: _PostReactionsContent(
        postId: postId,
        reactionSummary: reactionSummary,
      ),
    );
  }
}

class _PostReactionsContent extends StatefulWidget {
  final String postId;
  final List<Map<String, dynamic>> reactionSummary;

  const _PostReactionsContent({
    Key? key,
    required this.postId,
    required this.reactionSummary,
  }) : super(key: key);

  @override
  State<_PostReactionsContent> createState() => _PostReactionsContentState();
}

class _PostReactionsContentState extends State<_PostReactionsContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final tabs = ['all', ...widget.reactionSummary.map((r) => r['reactionType'] as String)];
    _tabController = TabController(length: tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final currentIndex = _tabController.index;
      if (currentIndex == 0) {
        context.read<ReactionBloc>().add(const ChangeReactionFilter(null));
      } else {
        final reactionType = widget.reactionSummary[currentIndex - 1]['reactionType'] as String;
        context.read<ReactionBloc>().add(ChangeReactionFilter(reactionType));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.feedBackground,
      appBar: AppBar(
        backgroundColor: AppColors.snow,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.feedTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tương tác',
          style: TextStyle(
            color: AppColors.feedTextPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.h),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.swan, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.feedTextPrimary,
              unselectedLabelColor: AppColors.feedTextSecondary,
              labelStyle: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                _buildTab('Tất cả', _getTotalCount()),
                ...widget.reactionSummary.map((r) {
                  final type = ReactionType.fromString(r['reactionType'] as String);
                  final count = r['count'] as int;
                  return _buildTab(type?.emoji ?? '🎉', count);
                }),
              ],
            ),
          ),
        ),
      ),
      body: BlocBuilder<ReactionBloc, ReactionState>(
        builder: (context, state) {
          if (state.status == ReactionStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ReactionStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48.sp, color: AppColors.cardinal),
                  SizedBox(height: 16.h),
                  Text('Đã xảy ra lỗi: ${state.errorMessage}'),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ReactionBloc>().add(
                        LoadPostReactions(postId: widget.postId),
                      );
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildReactionsList(),
              ...widget.reactionSummary.map((r) {
                return _buildReactionsList();
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTab(String label, int count) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          SizedBox(width: 6.w),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.feedTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  int _getTotalCount() {
    return widget.reactionSummary.fold<int>(0, (sum, r) => sum + (r['count'] as int));
  }

  Widget _buildReactionsList() {
    return BlocBuilder<ReactionBloc, ReactionState>(
      builder: (context, state) {
        List<FeedReactionEntity> reactions;
        final currentIndex = _tabController.index;
        
        if (currentIndex == 0) {
          reactions = state.reactions;
        } else {
          final reactionType = widget.reactionSummary[currentIndex - 1]['reactionType'] as String;
          reactions = state.reactions
              .where((r) => r.reactionType == reactionType)
              .toList();
        }
        
        if (reactions.isEmpty) {
          return Center(
            child: Text(
              'Chưa có tương tác nào',
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColors.feedTextSecondary,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          itemCount: reactions.length,
          itemBuilder: (context, index) {
            final reaction = reactions[index];
            return _buildUserReactionItem(reaction);
          },
        );
      },
    );
  }

  Widget _buildUserReactionItem(FeedReactionEntity reaction) {
    final reactionType = ReactionType.fromString(reaction.reactionType) ?? ReactionType.congrats;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          // Avatar với reaction emoji overlay
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 26.r,
                backgroundColor: AppColors.swan,
                backgroundImage: reaction.user.profilePictureUrl != null
                    ? NetworkImage(reaction.user.profilePictureUrl!)
                    : null,
                child: reaction.user.profilePictureUrl == null
                    ? Text(
                        reaction.user.displayName[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.wolf,
                        ),
                      )
                    : null,
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppColors.snow,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    reactionType.emoji,
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(width: 16.w),
          
          // Tên người dùng
          Expanded(
            child: Text(
              reaction.user.displayName,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.feedTextPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Nút Follow/Following
          _buildFollowButton(reaction.user.id),
        ],
      ),
    );
  }

  Widget _buildFollowButton(String userId) {
    return InkWell(
      onTap: () {
        // TODO: Implement follow functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tính năng follow đang phát triển')),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.macaw,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          Icons.person_add,
          size: 18.sp,
          color: AppColors.snow,
        ),
      ),
    );
  }
}
