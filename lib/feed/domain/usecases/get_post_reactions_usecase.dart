import 'package:vocabu_rex_mobile/feed/domain/entities/feed_reaction_entity.dart';
import 'package:vocabu_rex_mobile/feed/domain/repositories/feed_repository.dart';

class GetPostReactionsUseCase {
  final FeedRepository repository;

  GetPostReactionsUseCase(this.repository);

  Future<List<FeedReactionEntity>> call({
    required String postId,
    String? reactionType,
  }) async {
    return await repository.getPostReactions(
      postId: postId,
      reactionType: reactionType,
    );
  }
}
