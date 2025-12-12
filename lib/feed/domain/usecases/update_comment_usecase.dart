import 'package:vocabu_rex_mobile/feed/domain/repositories/feed_repository.dart';

class UpdateCommentUseCase {
  final FeedRepository repository;

  UpdateCommentUseCase(this.repository);

  Future<void> call({
    required String commentId,
    required String content,
  }) async {
    await repository.updateComment(
      commentId: commentId,
      content: content,
    );
  }
}
