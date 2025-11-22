import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/feed/data/models/feed_post_model.dart';
import 'package:vocabu_rex_mobile/feed/data/services/feed_service.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class FeedCommentsSheet extends StatefulWidget {
  final String postId;
  final List<FeedCommentModel> initialComments;
  final Function(String) onPostComment;

  const FeedCommentsSheet({
    Key? key,
    required this.postId,
    required this.initialComments,
    required this.onPostComment,
  }) : super(key: key);

  // Helper static function để gọi nhanh từ FeedPostCard
  static void show(
    BuildContext context, {
    required String postId,
    required List<FeedCommentModel> initialComments,
    required Function(String) onPostComment,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: AppColors.snow,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: FeedCommentsSheet(
          postId: postId,
          initialComments: initialComments,
          onPostComment: onPostComment,
        ),
      ),
    );
  }

  @override
  State<FeedCommentsSheet> createState() => _FeedCommentsSheetState();
}

class _FeedCommentsSheetState extends State<FeedCommentsSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FeedService _feedService = FeedService();
  
  List<FeedCommentModel> _currentComments = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _currentComments = List.from(widget.initialComments);
    _loadComments();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadComments();
    }
  }

  Future<void> _loadComments() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newComments = await _feedService.getPostComments(
        widget.postId,
        limit: _limit,
        offset: _offset,
      );

      setState(() {
        _currentComments.addAll(newComments);
        _offset += newComments.length;
        _hasMore = newComments.length == _limit;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải bình luận: $e')),
        );
      }
    }
  }

  void _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Call callback để parent component xử lý
    widget.onPostComment(text);
    _controller.clear();

    // Reload comments để lấy comment mới nhất
    setState(() {
      _offset = 0;
      _currentComments.clear();
      _hasMore = true;
    });
    await _loadComments();

    // Scroll về đầu list (comment mới nhất)
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Header Section (Nút X và Title)
        _buildHeader(context),

        const Divider(height: 1, thickness: 1, color: AppColors.feedDivider),

        // 2. List Comments
        Expanded(
          child: _currentComments.isEmpty && !_isLoading
              ? Center(
                  child: Text(
                    "Chưa có bình luận nào.",
                    style: TextStyle(color: AppColors.feedTextSecondary, fontSize: 14.sp),
                  ),
                )
              : ListView.separated(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16.w),
                  itemCount: _currentComments.length + (_isLoading ? 1 : 0),
                  separatorBuilder: (_, __) => SizedBox(height: 20.h),
                  itemBuilder: (context, index) {
                    if (index == _currentComments.length) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.h),
                          child: const CircularProgressIndicator(),
                        ),
                      );
                    }
                    return _buildCommentItem(_currentComments[index]);
                  },
                ),
        ),

        // 3. Input Footer
        _buildInputFooter(),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Title Center
          Text(
            'Bình luận',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.feedTextPrimary,
            ),
          ),
          // Close Button Left
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(Icons.close, size: 28.sp, color: AppColors.feedTextSecondary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(FeedCommentModel comment) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        CircleAvatar(
          radius: 20.r,
          backgroundColor: AppColors.swan,
          backgroundImage: comment.user.profilePictureUrl != null
              ? NetworkImage(comment.user.profilePictureUrl!)
              : null,
          child: comment.user.profilePictureUrl == null
              ? Text(
                  comment.user.displayName[0].toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.wolf,
                  ),
                )
              : null,
        ),
        SizedBox(width: 12.w),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name + Time
              Row(
                children: [
                  Text(
                    comment.user.displayName,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.feedTextPrimary,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _formatTimeAgo(comment.createdAt),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.feedTextSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),

              // Comment Text
              Text(
                comment.content,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.feedTextPrimary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputFooter() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h).add(
        EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      ),
      decoration: BoxDecoration(
        color: AppColors.snow,
        border: Border(top: BorderSide(color: AppColors.swan)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.polar,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: Colors.transparent),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Thêm bình luận...',
                    hintStyle: TextStyle(
                      color: AppColors.hare,
                      fontSize: 15.sp,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                  ),
                  style: TextStyle(fontSize: 15.sp),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: _handleSend,
              child: Container(
                padding: EdgeInsets.all(10.w),
                child: Icon(
                  Icons.send_rounded,
                  color: _controller.text.trim().isNotEmpty
                      ? AppColors.feedReactionActive
                      : AppColors.hare,
                  size: 28.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} tuần';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} tháng';
    } else {
      return '${(difference.inDays / 365).floor()} năm';
    }
  }
}
