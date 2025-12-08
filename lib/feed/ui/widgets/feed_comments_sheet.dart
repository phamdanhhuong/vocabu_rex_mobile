import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/feed/domain/entities/feed_comment_entity.dart';
import 'package:vocabu_rex_mobile/feed/ui/blocs/comment_bloc.dart';
import 'package:vocabu_rex_mobile/feed/ui/blocs/comment_event.dart';
import 'package:vocabu_rex_mobile/feed/ui/blocs/comment_state.dart';
import 'package:vocabu_rex_mobile/feed/data/datasources/feed_datasource_impl.dart';
import 'package:vocabu_rex_mobile/feed/data/repositories/feed_repository_impl.dart';
import 'package:vocabu_rex_mobile/feed/domain/usecases/get_post_comments_usecase.dart';
import 'package:vocabu_rex_mobile/feed/domain/usecases/add_comment_usecase.dart';
import 'package:vocabu_rex_mobile/feed/domain/usecases/delete_comment_usecase.dart';
import 'package:vocabu_rex_mobile/feed/ui/utils/feed_tokens.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/dot_loading_indicator.dart';

class FeedCommentsSheet extends StatelessWidget {
  final String postId;

  const FeedCommentsSheet({
    Key? key,
    required this.postId,
  }) : super(key: key);

  // Helper static function để gọi nhanh từ FeedPostCard
  static void show(
    BuildContext context, {
    required String postId,
  }) {
    final dataSource = FeedDataSourceImpl();
    final repository = FeedRepositoryImpl(dataSource);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider(
        create: (context) => CommentBloc(
          getPostCommentsUseCase: GetPostCommentsUseCase(repository),
          addCommentUseCase: AddCommentUseCase(repository),
          deleteCommentUseCase: DeleteCommentUseCase(repository),
        )..add(LoadPostComments(postId: postId)),
        child: Container(
          height: MediaQuery.of(context).size.height * FeedTokens.commentSheetHeightRatio,
          decoration: BoxDecoration(
            color: AppColors.snow,
            borderRadius: BorderRadius.vertical(top: Radius.circular(FeedTokens.radiusL)),
          ),
          child: FeedCommentsSheet(postId: postId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _FeedCommentsContent(postId: postId);
  }
}

class _FeedCommentsContent extends StatefulWidget {
  final String postId;

  const _FeedCommentsContent({
    Key? key,
    required this.postId,
  }) : super(key: key);

  @override
  State<_FeedCommentsContent> createState() => _FeedCommentsContentState();
}

class _FeedCommentsContentState extends State<_FeedCommentsContent> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - FeedTokens.scrollThreshold) {
      context.read<CommentBloc>().add(const LoadMoreComments());
    }
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    context.read<CommentBloc>().add(AddComment(
      postId: widget.postId,
      content: text,
    ));
    
    _controller.clear();

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
    return BlocConsumer<CommentBloc, CommentState>(
      listener: (context, state) {
        if (state.status == CommentStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Đã xảy ra lỗi')),
          );
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            // 1. Header Section (Nút X và Title)
            _buildHeader(context),

            Divider(height: FeedTokens.borderThin, thickness: FeedTokens.borderThin, color: AppColors.feedDivider),

            // 2. List Comments
            Expanded(
              child: _buildCommentsList(state),
            ),

            // 3. Input Footer
            _buildInputFooter(),
          ],
        );
      },
    );
  }

  Widget _buildCommentsList(CommentState state) {
    if (state.status == CommentStatus.loading && state.comments.isEmpty) {
      return Center(
        child: DotLoadingIndicator(
          color: AppColors.macaw,
          size: 16.0,
        ),
      );
    }

    if (state.comments.isEmpty && state.status != CommentStatus.loading) {
      return Center(
        child: Text(
          "Chưa có bình luận nào.",
          style: TextStyle(
            color: AppColors.feedTextSecondary, 
            fontSize: FeedTokens.fontS,
          ),
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.all(FeedTokens.cardPadding),
      itemCount: state.comments.length + (state.status == CommentStatus.loadingMore ? 1 : 0),
      separatorBuilder: (_, __) => SizedBox(height: FeedTokens.spacingXxl),
      itemBuilder: (context, index) {
        if (index == state.comments.length) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(FeedTokens.cardPadding),
              child: DotLoadingIndicator(
                color: AppColors.macaw,
                size: 16.0,
              ),
            ),
          );
        }
        return _buildCommentItem(state.comments[index]);
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: FeedTokens.spacingM, 
        vertical: FeedTokens.spacingL,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Title Center
          Text(
            'Bình luận',
            style: TextStyle(
              fontSize: FeedTokens.fontXl,
              fontWeight: FeedTokens.fontWeightBold,
              color: AppColors.feedTextPrimary,
            ),
          ),
          // Close Button Left
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(
                Icons.close, 
                size: FeedTokens.iconL, 
                color: AppColors.feedTextSecondary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(FeedCommentEntity comment) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        CircleAvatar(
          radius: FeedTokens.commentAvatarRadius,
          backgroundColor: AppColors.swan,
          backgroundImage: comment.user.profilePictureUrl != null
              ? NetworkImage(comment.user.profilePictureUrl!)
              : null,
          child: comment.user.profilePictureUrl == null
              ? Text(
                  comment.user.displayName[0].toUpperCase(),
                  style: TextStyle(
                    fontWeight: FeedTokens.fontWeightBold,
                    color: AppColors.wolf,
                  ),
                )
              : null,
        ),
        SizedBox(width: FeedTokens.spacingL),

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
                      fontSize: FeedTokens.fontM,
                      fontWeight: FeedTokens.fontWeightBold,
                      color: AppColors.feedTextPrimary,
                    ),
                  ),
                  SizedBox(width: FeedTokens.spacingM),
                  Text(
                    _formatTimeAgo(comment.createdAt),
                    style: TextStyle(
                      fontSize: FeedTokens.fontXs,
                      color: AppColors.feedTextSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: FeedTokens.spacingS),

              // Comment Text
              Text(
                comment.content,
                style: TextStyle(
                  fontSize: FeedTokens.fontM,
                  color: AppColors.feedTextPrimary,
                  height: FeedTokens.lineHeightTight,
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
      padding: EdgeInsets.symmetric(
        horizontal: FeedTokens.commentInputPaddingHorizontal, 
        vertical: FeedTokens.commentInputPaddingVertical,
      ).add(
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
                  borderRadius: BorderRadius.circular(FeedTokens.commentInputRadius),
                  border: Border.all(color: Colors.transparent),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Thêm bình luận...',
                    hintStyle: TextStyle(
                      color: AppColors.hare,
                      fontSize: FeedTokens.fontM,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: FeedTokens.cardPadding,
                      vertical: FeedTokens.reactionButtonPadding,
                    ),
                  ),
                  style: TextStyle(fontSize: FeedTokens.fontM),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),
            SizedBox(width: FeedTokens.spacingL),
            GestureDetector(
              onTap: _handleSend,
              child: Container(
                padding: EdgeInsets.all(FeedTokens.reactionButtonPadding),
                child: Icon(
                  Icons.send_rounded,
                  color: _controller.text.trim().isNotEmpty
                      ? AppColors.feedReactionActive
                      : AppColors.hare,
                  size: FeedTokens.commentSendIconSize,
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
