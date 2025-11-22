import 'package:vocabu_rex_mobile/feed/domain/entities/feed_post_entity.dart';
import 'package:vocabu_rex_mobile/feed/domain/repositories/feed_repository.dart';

class GetFeedPostsUseCase {
  final FeedRepository repository;

  GetFeedPostsUseCase(this.repository);

  Future<List<FeedPostEntity>> call({
    required int page,
    required int limit,
  }) async {
    return await repository.getFeedPosts(page: page, limit: limit);
  }
}
