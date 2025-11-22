import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/feed/domain/usecases/add_comment_usecase.dart';
import 'package:vocabu_rex_mobile/feed/domain/usecases/delete_comment_usecase.dart';
import 'package:vocabu_rex_mobile/feed/domain/usecases/get_feed_posts_usecase.dart';
import 'package:vocabu_rex_mobile/feed/domain/usecases/toggle_reaction_usecase.dart';
import 'package:vocabu_rex_mobile/feed/ui/blocs/feed_event.dart';
import 'package:vocabu_rex_mobile/feed/ui/blocs/feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final GetFeedPostsUseCase getFeedPostsUseCase;
  final ToggleReactionUseCase toggleReactionUseCase;
  final AddCommentUseCase addCommentUseCase;
  final DeleteCommentUseCase deleteCommentUseCase;

  static const int _postsPerPage = 20;

  FeedBloc({
    required this.getFeedPostsUseCase,
    required this.toggleReactionUseCase,
    required this.addCommentUseCase,
    required this.deleteCommentUseCase,
  }) : super(const FeedState()) {
    on<LoadFeedPosts>(_onLoadFeedPosts);
    on<TogglePostReaction>(_onTogglePostReaction);
    on<AddPostComment>(_onAddPostComment);
    on<DeletePostComment>(_onDeletePostComment);
    on<RefreshFeed>(_onRefreshFeed);
    on<LoadMorePosts>(_onLoadMorePosts);
    on<UpdatePostInList>(_onUpdatePostInList);
  }

  Future<void> _onLoadFeedPosts(
    LoadFeedPosts event,
    Emitter<FeedState> emit,
  ) async {
    try {
      if (event.isRefresh) {
        emit(state.copyWith(status: FeedStatus.loading, currentPage: 1, hasReachedMax: false));
      } else if (state.status == FeedStatus.initial) {
        emit(state.copyWith(status: FeedStatus.loading));
      }

      final posts = await getFeedPostsUseCase(
        page: event.page,
        limit: event.limit,
      );

      emit(state.copyWith(
        status: FeedStatus.success,
        posts: event.isRefresh ? posts : [...state.posts, ...posts],
        currentPage: event.page,
        hasReachedMax: posts.length < event.limit,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: FeedStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onTogglePostReaction(
    TogglePostReaction event,
    Emitter<FeedState> emit,
  ) async {
    try {
      await toggleReactionUseCase(
        postId: event.postId,
        reactionType: event.reactionType,
      );

      // Reload current page to get updated reactions
      add(LoadFeedPosts(page: state.currentPage, limit: _postsPerPage, isRefresh: true));
    } catch (error) {
      emit(state.copyWith(
        status: FeedStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onAddPostComment(
    AddPostComment event,
    Emitter<FeedState> emit,
  ) async {
    try {
      await addCommentUseCase(
        postId: event.postId,
        content: event.content,
      );

      // Reload to get updated comment count and latest comment
      add(LoadFeedPosts(page: state.currentPage, limit: _postsPerPage, isRefresh: true));
    } catch (error) {
      emit(state.copyWith(
        status: FeedStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onDeletePostComment(
    DeletePostComment event,
    Emitter<FeedState> emit,
  ) async {
    try {
      await deleteCommentUseCase(event.commentId);

      // Reload to get updated comment count
      add(LoadFeedPosts(page: state.currentPage, limit: _postsPerPage, isRefresh: true));
    } catch (error) {
      emit(state.copyWith(
        status: FeedStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onRefreshFeed(
    RefreshFeed event,
    Emitter<FeedState> emit,
  ) async {
    add(const LoadFeedPosts(page: 1, limit: _postsPerPage, isRefresh: true));
  }

  Future<void> _onLoadMorePosts(
    LoadMorePosts event,
    Emitter<FeedState> emit,
  ) async {
    if (state.hasReachedMax || state.status == FeedStatus.loadingMore) return;

    emit(state.copyWith(status: FeedStatus.loadingMore));
    add(LoadFeedPosts(page: state.currentPage + 1, limit: _postsPerPage));
  }

  void _onUpdatePostInList(
    UpdatePostInList event,
    Emitter<FeedState> emit,
  ) {
    final updatedPosts = state.posts.map((post) {
      return post.id == event.updatedPost.id ? event.updatedPost : post;
    }).toList();

    emit(state.copyWith(posts: updatedPosts));
  }
}
