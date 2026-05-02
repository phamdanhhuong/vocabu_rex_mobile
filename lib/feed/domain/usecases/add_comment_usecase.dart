import 'package:vocabu_rex_mobile/feed/domain/repositories/feed_repository.dart';

class AddCommentUseCase {
  final FeedRepository repository;

  AddCommentUseCase(this.repository);

  Future<void> call({required String postId, required String content}) async {
    await repository.addComment(postId: postId, content: content);
  }
}
