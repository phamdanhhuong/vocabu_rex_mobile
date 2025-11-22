import 'package:vocabu_rex_mobile/feed/domain/entities/feed_comment_entity.dart';
import 'package:vocabu_rex_mobile/feed/domain/repositories/feed_repository.dart';

class GetPostCommentsUseCase {
  final FeedRepository repository;

  GetPostCommentsUseCase(this.repository);

  Future<List<FeedCommentEntity>> call({
    required String postId,
    required int page,
    required int limit,
  }) async {
    return await repository.getPostComments(
      postId: postId,
      page: page,
      limit: limit,
    );
  }
}
