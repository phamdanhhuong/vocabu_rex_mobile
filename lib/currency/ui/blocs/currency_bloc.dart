import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/currency/domain/entities/currency_balance_entity.dart';
import 'package:vocabu_rex_mobile/currency/domain/usecases/get_currency_balance_usecase.dart';

// Events
abstract class CurrencyEvent {}
class GetCurrencyBalanceEvent extends CurrencyEvent {
  final String userId;
  GetCurrencyBalanceEvent(this.userId);
}

// States
abstract class CurrencyState {}
class CurrencyInitial extends CurrencyState {}
class CurrencyLoading extends CurrencyState {}
class CurrencyLoaded extends CurrencyState {
  final CurrencyBalanceEntity balance;
  CurrencyLoaded(this.balance);
}
class CurrencyError extends CurrencyState {
  final String message;
  CurrencyError(this.message);
}

// Bloc
class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  final GetCurrencyBalanceUseCase getCurrencyBalanceUseCase;

  CurrencyBloc({required this.getCurrencyBalanceUseCase}) : super(CurrencyInitial()) {
    on<GetCurrencyBalanceEvent>(_onGetCurrencyBalance);
  }

  Future<void> _onGetCurrencyBalance(GetCurrencyBalanceEvent event, Emitter<CurrencyState> emit) async {
    print('💰 CurrencyBloc: Getting currency balance for userId: ${event.userId}');
    emit(CurrencyLoading());
    try {
      final balance = await getCurrencyBalanceUseCase.call(event.userId);
      print('💰 CurrencyBloc: Balance loaded - Gems: ${balance.gems}, Coins: ${balance.coins}');
      emit(CurrencyLoaded(balance));
    } catch (e) {
      print('💰 CurrencyBloc: Error loading balance - ${e.toString()}');
      emit(CurrencyError(e.toString()));
    }
  }
}
