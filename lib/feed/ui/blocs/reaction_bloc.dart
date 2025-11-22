import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/feed/domain/usecases/get_post_reactions_usecase.dart';
import 'package:vocabu_rex_mobile/feed/ui/blocs/reaction_event.dart';
import 'package:vocabu_rex_mobile/feed/ui/blocs/reaction_state.dart';

class ReactionBloc extends Bloc<ReactionEvent, ReactionState> {
  final GetPostReactionsUseCase getPostReactionsUseCase;
  String? _currentPostId;

  ReactionBloc({
    required this.getPostReactionsUseCase,
  }) : super(const ReactionState()) {
    on<LoadPostReactions>(_onLoadPostReactions);
    on<ChangeReactionFilter>(_onChangeReactionFilter);
  }

  Future<void> _onLoadPostReactions(
    LoadPostReactions event,
    Emitter<ReactionState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ReactionStatus.loading));
      _currentPostId = event.postId;

      final reactions = await getPostReactionsUseCase(
        postId: event.postId,
        reactionType: event.reactionType,
      );

      emit(state.copyWith(
        status: ReactionStatus.success,
        reactions: reactions,
        currentFilter: event.reactionType,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: ReactionStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onChangeReactionFilter(
    ChangeReactionFilter event,
    Emitter<ReactionState> emit,
  ) async {
    if (_currentPostId == null) return;

    add(LoadPostReactions(
      postId: _currentPostId!,
      reactionType: event.reactionType,
    ));
  }
}
