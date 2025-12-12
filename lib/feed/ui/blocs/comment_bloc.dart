import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/feed/domain/usecases/add_comment_usecase.dart';
import 'package:vocabu_rex_mobile/feed/domain/usecases/delete_comment_usecase.dart';
import 'package:vocabu_rex_mobile/feed/domain/usecases/get_post_comments_usecase.dart';
import 'package:vocabu_rex_mobile/feed/domain/usecases/update_comment_usecase.dart';
import 'package:vocabu_rex_mobile/feed/ui/blocs/comment_event.dart';
import 'package:vocabu_rex_mobile/feed/ui/blocs/comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final GetPostCommentsUseCase getPostCommentsUseCase;
  final AddCommentUseCase addCommentUseCase;
  final DeleteCommentUseCase deleteCommentUseCase;
  final UpdateCommentUseCase updateCommentUseCase;

  String? _currentPostId;

  CommentBloc({
    required this.getPostCommentsUseCase,
    required this.addCommentUseCase,
    required this.deleteCommentUseCase,
    required this.updateCommentUseCase,
  }) : super(const CommentState()) {
    on<LoadPostComments>(_onLoadPostComments);
    on<AddComment>(_onAddComment);
    on<DeleteComment>(_onDeleteComment);
    on<UpdateComment>(_onUpdateComment);
    on<LoadMoreComments>(_onLoadMoreComments);
  }

  Future<void> _onLoadPostComments(
    LoadPostComments event,
    Emitter<CommentState> emit,
  ) async {
    try {
      _currentPostId = event.postId;

      if (event.isRefresh) {
        // Don't show loading indicator when refreshing
      } else if (state.status == CommentStatus.initial) {
        emit(state.copyWith(status: CommentStatus.loading));
      }

      final comments = await getPostCommentsUseCase(
        postId: event.postId,
        page: event.page,
        limit: event.limit,
      );

      emit(state.copyWith(
        status: CommentStatus.success,
        comments: event.isRefresh ? comments : [...state.comments, ...comments],
        currentPage: event.page,
        hasReachedMax: comments.length < event.limit,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: CommentStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onAddComment(
    AddComment event,
    Emitter<CommentState> emit,
  ) async {
    try {
      // Store the postId if not already set
      _currentPostId ??= event.postId;

      print('🔵 Adding comment for post: ${event.postId}');
      
      await addCommentUseCase(
        postId: event.postId,
        content: event.content,
      );

      print('✅ Comment added successfully, reloading comments...');

      // Reload comments to show the new one
      final comments = await getPostCommentsUseCase(
        postId: event.postId,
        page: 1,
        limit: 20,
      );

      print('📝 Loaded ${comments.length} comments');

      emit(state.copyWith(
        status: CommentStatus.success,
        comments: comments,
        currentPage: 1,
        hasReachedMax: comments.length < 20,
      ));

      print('✅ State emitted with ${comments.length} comments');
    } catch (error) {
      print('❌ Error adding comment: $error');
      emit(state.copyWith(
        status: CommentStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onDeleteComment(
    DeleteComment event,
    Emitter<CommentState> emit,
  ) async {
    try {
      await deleteCommentUseCase(event.commentId);

      // Remove comment from list
      final updatedComments = state.comments
          .where((comment) => comment.id != event.commentId)
          .toList();

      emit(state.copyWith(comments: updatedComments));
    } catch (error) {
      emit(state.copyWith(
        status: CommentStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onUpdateComment(
    UpdateComment event,
    Emitter<CommentState> emit,
  ) async {
    try {
      await updateCommentUseCase(
        commentId: event.commentId,
        content: event.content,
      );

      // Reload comments to show the updated one
      if (_currentPostId != null) {
        final comments = await getPostCommentsUseCase(
          postId: _currentPostId!,
          page: 1,
          limit: 20,
        );

        emit(state.copyWith(
          status: CommentStatus.success,
          comments: comments,
          currentPage: 1,
          hasReachedMax: comments.length < 20,
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        status: CommentStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onLoadMoreComments(
    LoadMoreComments event,
    Emitter<CommentState> emit,
  ) async {
    if (state.hasReachedMax || state.status == CommentStatus.loadingMore || _currentPostId == null) {
      return;
    }

    emit(state.copyWith(status: CommentStatus.loadingMore));
    add(LoadPostComments(postId: _currentPostId!, page: state.currentPage + 1, limit: 20));
  }
}
