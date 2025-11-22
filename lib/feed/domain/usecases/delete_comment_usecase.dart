import 'package:vocabu_rex_mobile/feed/domain/repositories/feed_repository.dart';

class DeleteCommentUseCase {
  final FeedRepository repository;

  DeleteCommentUseCase(this.repository);

  Future<void> call(String commentId) async {
    return await repository.deleteComment(commentId);
  }
}
