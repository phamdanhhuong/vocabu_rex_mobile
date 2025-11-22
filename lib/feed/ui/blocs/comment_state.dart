import 'package:equatable/equatable.dart';
import 'package:vocabu_rex_mobile/feed/domain/entities/feed_comment_entity.dart';

enum CommentStatus { initial, loading, success, failure, loadingMore }

class CommentState extends Equatable {
  final CommentStatus status;
  final List<FeedCommentEntity> comments;
  final String? errorMessage;
  final int currentPage;
  final bool hasReachedMax;

  const CommentState({
    this.status = CommentStatus.initial,
    this.comments = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasReachedMax = false,
  });

  CommentState copyWith({
    CommentStatus? status,
    List<FeedCommentEntity>? comments,
    String? errorMessage,
    int? currentPage,
    bool? hasReachedMax,
  }) {
    return CommentState(
      status: status ?? this.status,
      comments: comments ?? this.comments,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [status, comments, errorMessage, currentPage, hasReachedMax];
}
