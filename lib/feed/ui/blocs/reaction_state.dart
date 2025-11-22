import 'package:equatable/equatable.dart';
import 'package:vocabu_rex_mobile/feed/domain/entities/feed_reaction_entity.dart';

enum ReactionStatus { initial, loading, success, failure }

class ReactionState extends Equatable {
  final ReactionStatus status;
  final List<FeedReactionEntity> reactions;
  final String? errorMessage;
  final String? currentFilter;

  const ReactionState({
    this.status = ReactionStatus.initial,
    this.reactions = const [],
    this.errorMessage,
    this.currentFilter,
  });

  ReactionState copyWith({
    ReactionStatus? status,
    List<FeedReactionEntity>? reactions,
    String? errorMessage,
    String? currentFilter,
  }) {
    return ReactionState(
      status: status ?? this.status,
      reactions: reactions ?? this.reactions,
      errorMessage: errorMessage,
      currentFilter: currentFilter ?? this.currentFilter,
    );
  }

  @override
  List<Object?> get props => [status, reactions, errorMessage, currentFilter];
}
