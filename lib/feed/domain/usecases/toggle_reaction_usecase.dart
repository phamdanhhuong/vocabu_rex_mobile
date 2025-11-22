import 'package:vocabu_rex_mobile/feed/domain/repositories/feed_repository.dart';

class ToggleReactionUseCase {
  final FeedRepository repository;

  ToggleReactionUseCase(this.repository);

  Future<void> call({
    required String postId,
    required String reactionType,
  }) async {
    return await repository.toggleReaction(
      postId: postId,
      reactionType: reactionType,
    );
  }
}
