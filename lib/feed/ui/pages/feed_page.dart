import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/feed/ui/blocs/feed_bloc.dart';
import 'package:vocabu_rex_mobile/feed/ui/blocs/feed_event.dart';
import 'package:vocabu_rex_mobile/feed/ui/blocs/feed_state.dart';
import 'package:vocabu_rex_mobile/feed/data/datasources/feed_datasource_impl.dart';
import 'package:vocabu_rex_mobile/feed/data/repositories/feed_repository_impl.dart';
import 'package:vocabu_rex_mobile/feed/domain/usecases/get_feed_posts_usecase.dart';
import 'package:vocabu_rex_mobile/feed/domain/usecases/toggle_reaction_usecase.dart';
import 'package:vocabu_rex_mobile/feed/domain/usecases/add_comment_usecase.dart';
import 'package:vocabu_rex_mobile/feed/domain/usecases/delete_comment_usecase.dart';
import 'package:vocabu_rex_mobile/feed/ui/widgets/feed_post_card.dart';
import 'package:vocabu_rex_mobile/feed/ui/widgets/feed_comments_sheet.dart';
import 'package:vocabu_rex_mobile/feed/ui/pages/post_reactions_page.dart';
import 'package:vocabu_rex_mobile/core/token_manager.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataSource = FeedDataSourceImpl();
    final repository = FeedRepositoryImpl(dataSource);

    return BlocProvider(
      create: (context) => FeedBloc(
        getFeedPostsUseCase: GetFeedPostsUseCase(repository),
        toggleReactionUseCase: ToggleReactionUseCase(repository),
        addCommentUseCase: AddCommentUseCase(repository),
        deleteCommentUseCase: DeleteCommentUseCase(repository),
      )..add(const LoadFeedPosts(page: 1, limit: 20)),
      child: const _FeedPageContent(),
    );
  }
}

class _FeedPageContent extends StatefulWidget {
  const _FeedPageContent({Key? key}) : super(key: key);

  @override
  State<_FeedPageContent> createState() => _FeedPageContentState();
}

class _FeedPageContentState extends State<_FeedPageContent> {
  final ScrollController _scrollController = ScrollController();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadCurrentUser() async {
    try {
      final userInfo = await TokenManager.getUserInfo();
      setState(() {
        _currentUserId = userInfo['userId'];
      });
    } catch (e) {
      // Handle error
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<FeedBloc>().add(const LoadMorePosts());
    }
  }

  void _handleReaction(String postId, String reactionType) {
    context.read<FeedBloc>().add(TogglePostReaction(
      postId: postId,
      reactionType: reactionType,
    ));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã react!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _handleDelete(String postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa bài đăng'),
        content: const Text('Bạn có chắc muốn xóa bài đăng này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: AppColors.cardinal)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Add delete post to domain layer
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tính năng xóa bài đăng đang phát triển')),
      );
    }
  }

  void _navigateToComments(String postId, dynamic latestComment) {
    FeedCommentsSheet.show(
      context,
      postId: postId,
      initialComments: latestComment != null ? [latestComment] : [],
      onPostComment: (content) => _handleQuickComment(postId, content),
    );
  }

  void _showReactionsList(String postId, List<dynamic> reactions) {
    final reactionSummary = reactions.map((r) => {
      'reactionType': r.reactionType,
      'count': r.count,
    }).toList();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostReactionsPage(
          postId: postId,
          reactionSummary: reactionSummary,
        ),
      ),
    );
  }

  void _handleQuickComment(String postId, String content) {
    context.read<FeedBloc>().add(AddPostComment(
      postId: postId,
      content: content,
    ));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã thêm bình luận!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _navigateToUserProfile(String userId) {
    // TODO: Implement user profile navigation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng xem profile đang phát triển')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.feedBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.snow,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Bảng tin',
          style: TextStyle(
            color: AppColors.hare,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(
            color: AppColors.swan,
            height: 2.0,
          ),
        ),
      ),
      body: BlocConsumer<FeedBloc, FeedState>(
        listener: (context, state) {
          if (state.status == FeedStatus.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi: ${state.errorMessage}')),
            );
          }
        },
        builder: (context, state) {
          if (state.status == FeedStatus.loading && state.posts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.feed_outlined,
                    size: 80.sp,
                    color: AppColors.feedTextSecondary,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Chưa có bài đăng nào',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.feedTextSecondary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Follow bạn bè để xem feed của họ!',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.feedTextSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<FeedBloc>().add(const RefreshFeed());
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
              itemCount: state.posts.length + (state.status == FeedStatus.loadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.posts.length) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.h),
                      child: const CircularProgressIndicator(),
                    ),
                  );
                }

                final post = state.posts[index];
                return FeedPostCard(
                  post: post,
                  currentUserId: _currentUserId,
                  onReaction: (reactionType) => _handleReaction(post.id, reactionType),
                  onComment: () => _navigateToComments(post.id, post.latestComment),
                  onDelete: post.userId == _currentUserId
                      ? () => _handleDelete(post.id)
                      : null,
                  onUserTap: () => _navigateToUserProfile(post.userId),
                  onViewReactions: () => _showReactionsList(post.id, post.reactions),
                  onViewComments: () => _navigateToComments(post.id, post.latestComment),
                  onQuickComment: (content) => _handleQuickComment(post.id, content),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
