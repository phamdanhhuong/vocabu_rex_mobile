import 'package:vocabu_rex_mobile/feed/domain/entities/feed_comment_entity.dart';
import 'package:vocabu_rex_mobile/feed/domain/repositories/feed_repository.dart';

class AddCommentUseCase {
  final FeedRepository repository;

  AddCommentUseCase(this.repository);

  Future<FeedCommentEntity> call({
    required String postId,
    required String content,
  }) async {
    return await repository.addComment(
      postId: postId,
      content: content,
    );
  }
}
