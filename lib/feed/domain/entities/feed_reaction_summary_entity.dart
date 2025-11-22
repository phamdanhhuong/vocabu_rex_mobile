import 'package:vocabu_rex_mobile/feed/data/models/feed_post_model.dart';

class FeedReactionSummaryEntity {
  final String reactionType;
  final int count;

  FeedReactionSummaryEntity({
    required this.reactionType,
    required this.count,
  });

  factory FeedReactionSummaryEntity.fromModel(FeedReactionSummary model) {
    return FeedReactionSummaryEntity(
      reactionType: model.reactionType,
      count: model.count,
    );
  }
}
