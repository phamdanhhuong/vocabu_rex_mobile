import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/feed/domain/usecases/add_comment_usecase.dart';
import 'package:vocabu_rex_mobile/feed/domain/usecases/delete_comment_usecase.dart';
import 'package:vocabu_rex_mobile/feed/domain/usecases/get_post_comments_usecase.dart';
import 'package:vocabu_rex_mobile/feed/ui/blocs/comment_event.dart';
import 'package:vocabu_rex_mobile/feed/ui/blocs/comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final GetPostCommentsUseCase getPostCommentsUseCase;
  final AddCommentUseCase addCommentUseCase;
  final DeleteCommentUseCase deleteCommentUseCase;

  String? _currentPostId;

  CommentBloc({
    required this.getPostCommentsUseCase,
    required this.addCommentUseCase,
    required this.deleteCommentUseCase,
  }) : super(const CommentState()) {
    on<LoadPostComments>(_onLoadPostComments);
    on<AddComment>(_onAddComment);
    on<DeleteComment>(_onDeleteComment);
    on<LoadMoreComments>(_onLoadMoreComments);
  }

  Future<void> _onLoadPostComments(
    LoadPostComments event,
    Emitter<CommentState> emit,
  ) async {
    try {
      _currentPostId = event.postId;

      if (event.isRefresh) {
        emit(state.copyWith(status: CommentStatus.loading, currentPage: 1, hasReachedMax: false));
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
      final newComment = await addCommentUseCase(
        postId: event.postId,
        content: event.content,
      );

      // Add new comment to the beginning of the list
      emit(state.copyWith(
        comments: [newComment, ...state.comments],
      ));
    } catch (error) {
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
