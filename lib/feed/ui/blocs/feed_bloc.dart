import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/feed/domain/usecases/add_comment_usecase.dart';
import 'package:vocabu_rex_mobile/feed/domain/usecases/delete_comment_usecase.dart';
import 'package:vocabu_rex_mobile/feed/domain/usecases/get_feed_posts_usecase.dart';
import 'package:vocabu_rex_mobile/feed/domain/usecases/toggle_reaction_usecase.dart';
import 'package:vocabu_rex_mobile/feed/ui/blocs/feed_event.dart';
import 'package:vocabu_rex_mobile/feed/domain/entities/feed_post_entity.dart';
import 'package:vocabu_rex_mobile/feed/domain/entities/feed_reaction_summary_entity.dart';
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
        emit(
          state.copyWith(
            status: FeedStatus.loading,
            currentPage: 1,
            hasReachedMax: false,
          ),
        );
      } else if (state.status == FeedStatus.initial) {
        emit(state.copyWith(status: FeedStatus.loading));
      }

      final posts = await getFeedPostsUseCase(
        page: event.page,
        limit: event.limit,
      );

      emit(
        state.copyWith(
          status: FeedStatus.success,
          posts: event.isRefresh ? posts : [...state.posts, ...posts],
          currentPage: event.page,
          hasReachedMax: posts.length < event.limit,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: FeedStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onTogglePostReaction(
    TogglePostReaction event,
    Emitter<FeedState> emit,
  ) async {
    try {
      // Optimistic update
      final postIndex = state.posts.indexWhere((p) => p.id == event.postId);
      if (postIndex != -1) {
        final currentPost = state.posts[postIndex];
        
        String? newUserReaction = event.reactionType;
        bool clearUserReaction = false;
        final updatedReactions = List<FeedReactionSummaryEntity>.from(currentPost.reactions);

        // Remove old reaction count
        if (currentPost.userReaction != null) {
          final oldReactionIndex = updatedReactions.indexWhere((r) => r.reactionType == currentPost.userReaction);
          if (oldReactionIndex != -1) {
             final oldCount = updatedReactions[oldReactionIndex].count;
             if (oldCount <= 1) {
                updatedReactions.removeAt(oldReactionIndex);
             } else {
                updatedReactions[oldReactionIndex] = updatedReactions[oldReactionIndex].copyWith(count: oldCount - 1);
             }
          }
        }
        
        if (currentPost.userReaction == event.reactionType) {
           newUserReaction = null;
           clearUserReaction = true;
        } else {
           // Add new reaction count
           final newReactionIndex = updatedReactions.indexWhere((r) => r.reactionType == event.reactionType);
           if (newReactionIndex != -1) {
              updatedReactions[newReactionIndex] = updatedReactions[newReactionIndex].copyWith(
                 count: updatedReactions[newReactionIndex].count + 1
              );
           } else {
              updatedReactions.add(FeedReactionSummaryEntity(reactionType: event.reactionType, count: 1));
           }
        }

        final updatedPost = currentPost.copyWith(
          userReaction: newUserReaction,
          clearUserReaction: clearUserReaction,
          reactions: updatedReactions,
        );
        
        final updatedPosts = List<FeedPostEntity>.from(state.posts);
        updatedPosts[postIndex] = updatedPost;
        
        emit(state.copyWith(posts: updatedPosts));
      }

      // Fire and forget to allow fast navigation without cancelling
      toggleReactionUseCase(
        postId: event.postId,
        reactionType: event.reactionType,
      ).catchError((error) {
        if (!isClosed) {
          emit(
            state.copyWith(
              status: FeedStatus.failure,
              errorMessage: error.toString(),
            ),
          );
        }
      });
    } catch (error) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: FeedStatus.failure,
            errorMessage: error.toString(),
          ),
        );
      }
    }
  }

  Future<void> _onAddPostComment(
    AddPostComment event,
    Emitter<FeedState> emit,
  ) async {
    try {
      await addCommentUseCase(postId: event.postId, content: event.content);

      // Reload to get updated comment count and latest comment
      add(
        LoadFeedPosts(
          page: state.currentPage,
          limit: _postsPerPage,
          isRefresh: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: FeedStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onDeletePostComment(
    DeletePostComment event,
    Emitter<FeedState> emit,
  ) async {
    try {
      await deleteCommentUseCase(event.commentId);

      // Reload to get updated comment count
      add(
        LoadFeedPosts(
          page: state.currentPage,
          limit: _postsPerPage,
          isRefresh: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: FeedStatus.failure,
          errorMessage: error.toString(),
        ),
      );
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

  void _onUpdatePostInList(UpdatePostInList event, Emitter<FeedState> emit) {
    final updatedPosts = state.posts.map((post) {
      return post.id == event.updatedPost.id ? event.updatedPost : post;
    }).toList();

    emit(state.copyWith(posts: updatedPosts));
  }
}
