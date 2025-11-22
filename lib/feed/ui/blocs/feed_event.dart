import 'package:equatable/equatable.dart';
import 'package:vocabu_rex_mobile/feed/domain/entities/feed_post_entity.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

class LoadFeedPosts extends FeedEvent {
  final int page;
  final int limit;
  final bool isRefresh;

  const LoadFeedPosts({
    this.page = 1,
    this.limit = 20,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [page, limit, isRefresh];
}

class TogglePostReaction extends FeedEvent {
  final String postId;
  final String reactionType;

  const TogglePostReaction({
    required this.postId,
    required this.reactionType,
  });

  @override
  List<Object?> get props => [postId, reactionType];
}

class AddPostComment extends FeedEvent {
  final String postId;
  final String content;

  const AddPostComment({
    required this.postId,
    required this.content,
  });

  @override
  List<Object?> get props => [postId, content];
}

class DeletePostComment extends FeedEvent {
  final String commentId;
  final String postId;

  const DeletePostComment({
    required this.commentId,
    required this.postId,
  });

  @override
  List<Object?> get props => [commentId, postId];
}

class RefreshFeed extends FeedEvent {
  const RefreshFeed();
}

class LoadMorePosts extends FeedEvent {
  const LoadMorePosts();
}

class UpdatePostInList extends FeedEvent {
  final FeedPostEntity updatedPost;

  const UpdatePostInList(this.updatedPost);

  @override
  List<Object?> get props => [updatedPost];
}
