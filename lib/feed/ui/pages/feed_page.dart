import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/feed/data/models/feed_post_model.dart';
import 'package:vocabu_rex_mobile/feed/data/services/feed_service.dart';
import 'package:vocabu_rex_mobile/feed/ui/widgets/feed_post_card.dart';
import 'package:vocabu_rex_mobile/feed/ui/widgets/feed_comments_sheet.dart';
import 'package:vocabu_rex_mobile/feed/ui/pages/post_reactions_page.dart';
import 'package:vocabu_rex_mobile/core/token_manager.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final FeedService _feedService = FeedService();
  final ScrollController _scrollController = ScrollController();

  List<FeedPostModel> _posts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 20;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadFeed();
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

  Future<void> _loadFeed({bool refresh = false}) async {
    if (_isLoading) return;
    if (!refresh && !_hasMore) return;

    setState(() {
      _isLoading = true;
      if (refresh) {
        _offset = 0;
        _posts = [];
        _hasMore = true;
      }
    });

    try {
      final newPosts = await _feedService.getFeed(
        limit: _limit,
        offset: _offset,
      );

      setState(() {
        if (refresh) {
          _posts = newPosts;
        } else {
          _posts.addAll(newPosts);
        }
        _offset += newPosts.length;
        _hasMore = newPosts.length == _limit;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải feed: $e')),
        );
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadFeed();
    }
  }

  Future<void> _handleReaction(String postId, String reactionType) async {
    try {
      await _feedService.toggleReaction(postId, reactionType);
      
      // Refresh the feed to update reaction counts
      await _loadFeed(refresh: true);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã react!'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
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
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _feedService.deletePost(postId);
        await _loadFeed(refresh: true);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa bài đăng')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi xóa: $e')),
          );
        }
      }
    }
  }

  void _navigateToComments(FeedPostModel post) {
    FeedCommentsSheet.show(
      context,
      postId: post.id,
      initialComments: post.latestComment != null ? [post.latestComment!] : [],
      onPostComment: (content) => _handleQuickComment(post.id, content),
    );
  }

  void _showReactionsList(String postId) {
    // Tìm post để lấy reaction summary
    final post = _posts.firstWhere((p) => p.id == postId);
    
    // Chuyển đổi sang format phù hợp
    final reactionSummary = post.reactions.map((r) => {
      'reactionType': r.reactionType,
      'count': r.count,
    }).toList();
    
    // Navigate đến trang reactions với slide ngang
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

  Future<void> _handleQuickComment(String postId, String content) async {
    try {
      await _feedService.addComment(postId, content);
      await _loadFeed(refresh: true);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm bình luận!'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
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
        backgroundColor: Colors.white,
        elevation: 0, // Xóa bóng đổ mặc định để dùng đường kẻ custom
        centerTitle: true, // Căn giữa tiêu đề
        title: Text(
          'Bảng tin',
          style: TextStyle(
            color: const Color(0xFFAFB6BC), // Mã màu xám nhạt giống trong hình
            fontWeight: FontWeight.bold,
            fontSize: 20.sp, // Dùng screenutil cho kích thước chữ
          ),
        ),
        // Tạo đường kẻ ngang bên dưới Header
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(
            color: const Color(0xFFE5E5E5), // Màu của đường kẻ
            height: 2.0, // Độ dày đường kẻ
          ),
        ),
        // Mình đã bỏ phần actions (nút refresh) để giống hệt hình mẫu sạch sẽ
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadFeed(refresh: true),
        child: _posts.isEmpty && _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _posts.isEmpty
                ? Center(
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
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
                    itemCount: _posts.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _posts.length) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.h),
                            child: const CircularProgressIndicator(),
                          ),
                        );
                      }

                      final post = _posts[index];
                      return FeedPostCard(
                        post: post,
                        currentUserId: _currentUserId,
                        onReaction: (reactionType) => _handleReaction(post.id, reactionType),
                        onComment: () => _navigateToComments(post),
                        onDelete: post.userId == _currentUserId
                            ? () => _handleDelete(post.id)
                            : null,
                        onUserTap: () => _navigateToUserProfile(post.userId),
                        onViewReactions: () => _showReactionsList(post.id),
                        onViewComments: () => _navigateToComments(post),
                        onQuickComment: (content) => _handleQuickComment(post.id, content),
                      );
                    },
                  ),
      ),
    );
  }
}
