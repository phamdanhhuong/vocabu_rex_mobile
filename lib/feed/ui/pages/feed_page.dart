import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vocabu_rex_mobile/feed/ui/blocs/feed_bloc.dart';
import 'package:vocabu_rex_mobile/feed/ui/blocs/feed_event.dart';
import 'package:vocabu_rex_mobile/feed/ui/blocs/feed_state.dart';
import 'package:vocabu_rex_mobile/feed/ui/widgets/feed_post_card.dart';
import 'package:vocabu_rex_mobile/feed/ui/widgets/feed_comments_sheet.dart';
import 'package:vocabu_rex_mobile/feed/ui/pages/post_reactions_page.dart';
import 'package:vocabu_rex_mobile/core/token_manager.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/dot_loading_indicator.dart';
import 'package:vocabu_rex_mobile/profile/ui/pages/public_profile_page.dart';
import 'package:vocabu_rex_mobile/theme/widgets/static_space_background.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  @override
  void initState() {
    super.initState();
    // Load feed posts when page loads
    context.read<FeedBloc>().add(
      const LoadFeedPosts(page: 1, limit: 20, isRefresh: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const _FeedPageContent();
  }
}

class _FeedPageContent extends StatefulWidget {
  const _FeedPageContent();

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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<FeedBloc>().add(const LoadMorePosts());
    }
  }

  void _handleReaction(String postId, String reactionType) {
    context.read<FeedBloc>().add(
      TogglePostReaction(postId: postId, reactionType: reactionType),
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
            child: const Text(
              'Xóa',
              style: TextStyle(color: AppColors.cardinal),
            ),
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
    FeedCommentsSheet.show(context, postId: postId);
  }

  void _showReactionsList(String postId, List<dynamic> reactions) {
    final reactionSummary = reactions
        .map((r) => {'reactionType': r.reactionType, 'count': r.count})
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PostReactionsPage(postId: postId, reactionSummary: reactionSummary),
      ),
    );
  }

  void _handleQuickComment(String postId, String content) {
    context.read<FeedBloc>().add(
      AddPostComment(postId: postId, content: content),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã thêm bình luận!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _navigateToUserProfile(String userId, String userName) {
    if (userId == _currentUserId) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PublicProfilePage(
          userId: userId,
          userName: userName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StaticSpaceBackground(
      child: Scaffold(
      backgroundColor: Colors.transparent,
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
          child: Container(color: AppColors.swan, height: 2.0),
        ),
      ),
      body: BlocConsumer<FeedBloc, FeedState>(
        listener: (context, state) {
          if (state.status == FeedStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi: ${state.errorMessage}')),
            );
          }
        },
        builder: (context, state) {
          if (state.status == FeedStatus.loading && state.posts.isEmpty) {
            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: AppColors.swan.withOpacity(0.5),
                  highlightColor: AppColors.snow,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(width: 48.w, height: 48.w, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                              SizedBox(width: 12.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(width: 150.w, height: 16.h, color: Colors.white),
                                  SizedBox(height: 8.h),
                                  Container(width: 100.w, height: 12.h, color: Colors.white),
                                ],
                              )
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Container(width: double.infinity, height: 100.h, color: Colors.white),
                          SizedBox(height: 16.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(width: 80.w, height: 36.h, color: Colors.white),
                              Container(width: 80.w, height: 36.h, color: Colors.white),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = kIsWeb && constraints.maxWidth >= 768;

                Widget listContent = ListView.builder(
                  controller: _scrollController,
                  padding: isWide
                      ? EdgeInsets.symmetric(vertical: 24.h)
                      : EdgeInsets.only(top: 8.h, bottom: 16.h),
                  itemCount:
                      state.posts.length +
                      (state.status == FeedStatus.loadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == state.posts.length) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.h),
                          child: const DotLoadingIndicator(
                            color: AppColors.macaw,
                            size: 16,
                          ),
                        ),
                      );
                    }

                    final post = state.posts[index];
                    // Calculate a bounded delay for cascading effect
                    final delayMs = (index % 10) * 100;
                    return FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      delay: Duration(milliseconds: delayMs),
                      child: FeedPostCard(
                        post: post,
                        currentUserId: _currentUserId,
                        onReaction: (reactionType) =>
                            _handleReaction(post.id, reactionType),
                        onComment: () =>
                            _navigateToComments(post.id, post.latestComment),
                        onDelete: post.userId == _currentUserId
                            ? () => _handleDelete(post.id)
                            : null,
                        onUserTap: () => _navigateToUserProfile(post.user.id, post.user.displayName),
                        onViewReactions: () =>
                            _showReactionsList(post.id, post.reactions),
                        onViewComments: () =>
                            _navigateToComments(post.id, post.latestComment),
                        onQuickComment: (content) =>
                            _handleQuickComment(post.id, content),
                      ),
                    );
                  },
                );

                if (isWide) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: listContent,
                    ),
                  );
                }
                return listContent;
              },
            ),
          );
        },
      ),
      ),
    );
  }
}
