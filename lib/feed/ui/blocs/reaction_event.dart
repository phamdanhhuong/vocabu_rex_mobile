import 'package:equatable/equatable.dart';

sealed class ReactionEvent extends Equatable {
  const ReactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadPostReactions extends ReactionEvent {
  final String postId;
  final String? reactionType;

  const LoadPostReactions({
    required this.postId,
    this.reactionType,
  });

  @override
  List<Object?> get props => [postId, reactionType];
}

class ChangeReactionFilter extends ReactionEvent {
  final String? reactionType;

  const ChangeReactionFilter(this.reactionType);

  @override
  List<Object?> get props => [reactionType];
}
