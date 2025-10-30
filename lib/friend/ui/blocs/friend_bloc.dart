import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/friend/domain/entities/user_entity.dart';
import 'package:vocabu_rex_mobile/friend/domain/usecases/search_users_usecase.dart';
import 'package:vocabu_rex_mobile/friend/domain/usecases/get_suggested_friends_usecase.dart';
import 'package:vocabu_rex_mobile/friend/domain/usecases/follow_user_usecase.dart';
import 'package:vocabu_rex_mobile/friend/domain/usecases/unfollow_user_usecase.dart';

// Events
abstract class FriendEvent {}

class SearchUsersEvent extends FriendEvent {
  final String query;
  SearchUsersEvent(this.query);
}

class GetSuggestedFriendsEvent extends FriendEvent {
  GetSuggestedFriendsEvent();
}

class FollowUserEvent extends FriendEvent {
  final String userId;
  FollowUserEvent(this.userId);
}

class UnfollowUserEvent extends FriendEvent {
  final String userId;
  UnfollowUserEvent(this.userId);
}

class ClearSearchEvent extends FriendEvent {}

// States
abstract class FriendState {}

class FriendInit extends FriendState {}

class FriendLoading extends FriendState {}

class SuggestedFriendsLoaded extends FriendState {
  final List<UserEntity> suggestions;
  SuggestedFriendsLoaded({required this.suggestions});
}

class SearchResultsLoaded extends FriendState {
  final List<UserEntity> searchResults;
  final String query;
  SearchResultsLoaded({required this.searchResults, required this.query});
}

class FriendError extends FriendState {
  final String message;
  FriendError({required this.message});
}

class FollowActionInProgress extends FriendState {}

class FollowActionSuccess extends FriendState {
  final String userId;
  final bool isFollowing;
  FollowActionSuccess({required this.userId, required this.isFollowing});
}

class FollowActionError extends FriendState {
  final String message;
  FollowActionError({required this.message});
}

// Bloc
class FriendBloc extends Bloc<FriendEvent, FriendState> {
  final SearchUsersUsecase searchUsersUsecase;
  final GetSuggestedFriendsUsecase getSuggestedFriendsUsecase;
  final FollowUserUsecase followUserUsecase;
  final UnfollowUserUsecase unfollowUserUsecase;

  FriendBloc({
    required this.searchUsersUsecase,
    required this.getSuggestedFriendsUsecase,
    required this.followUserUsecase,
    required this.unfollowUserUsecase,
  }) : super(FriendInit()) {
    // Search Users
    on<SearchUsersEvent>((event, emit) async {
      if (event.query.isEmpty) {
        emit(FriendInit());
        return;
      }
      
      emit(FriendLoading());
      try {
        final results = await searchUsersUsecase(event.query);
        emit(SearchResultsLoaded(searchResults: results, query: event.query));
      } catch (e) {
        emit(FriendError(message: e.toString()));
      }
    });

    // Get Suggested Friends
    on<GetSuggestedFriendsEvent>((event, emit) async {
      emit(FriendLoading());
      try {
        final suggestions = await getSuggestedFriendsUsecase();
        emit(SuggestedFriendsLoaded(suggestions: suggestions));
      } catch (e) {
        emit(FriendError(message: e.toString()));
      }
    });

    // Follow User
    on<FollowUserEvent>((event, emit) async {
      emit(FollowActionInProgress());
      try {
        await followUserUsecase(event.userId);
        emit(FollowActionSuccess(userId: event.userId, isFollowing: true));
        // Refresh suggestions or search results
        add(GetSuggestedFriendsEvent());
      } catch (e) {
        emit(FollowActionError(message: e.toString()));
      }
    });

    // Unfollow User
    on<UnfollowUserEvent>((event, emit) async {
      emit(FollowActionInProgress());
      try {
        await unfollowUserUsecase(event.userId);
        emit(FollowActionSuccess(userId: event.userId, isFollowing: false));
        // Refresh suggestions or search results
        add(GetSuggestedFriendsEvent());
      } catch (e) {
        emit(FollowActionError(message: e.toString()));
      }
    });

    // Clear Search
    on<ClearSearchEvent>((event, emit) async {
      emit(FriendInit());
    });
  }
}
