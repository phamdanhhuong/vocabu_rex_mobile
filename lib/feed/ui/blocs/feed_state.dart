import 'package:equatable/equatable.dart';
import 'package:vocabu_rex_mobile/feed/domain/entities/feed_post_entity.dart';

enum FeedStatus { initial, loading, success, failure, loadingMore }

class FeedState extends Equatable {
  final FeedStatus status;
  final List<FeedPostEntity> posts;
  final String? errorMessage;
  final int currentPage;
  final bool hasReachedMax;

  const FeedState({
    this.status = FeedStatus.initial,
    this.posts = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasReachedMax = false,
  });

  FeedState copyWith({
    FeedStatus? status,
    List<FeedPostEntity>? posts,
    String? errorMessage,
    int? currentPage,
    bool? hasReachedMax,
  }) {
    return FeedState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [status, posts, errorMessage, currentPage, hasReachedMax];
}
