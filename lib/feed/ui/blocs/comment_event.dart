import 'package:equatable/equatable.dart';

sealed class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object?> get props => [];
}

class LoadPostComments extends CommentEvent {
  final String postId;
  final int page;
  final int limit;
  final bool isRefresh;

  const LoadPostComments({
    required this.postId,
    this.page = 1,
    this.limit = 20,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [postId, page, limit, isRefresh];
}

class AddComment extends CommentEvent {
  final String postId;
  final String content;

  const AddComment({
    required this.postId,
    required this.content,
  });

  @override
  List<Object?> get props => [postId, content];
}

class DeleteComment extends CommentEvent {
  final String commentId;

  const DeleteComment(this.commentId);

  @override
  List<Object?> get props => [commentId];
}

class LoadMoreComments extends CommentEvent {
  const LoadMoreComments();
}
