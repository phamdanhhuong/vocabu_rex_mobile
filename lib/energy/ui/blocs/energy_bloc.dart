import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/energy/domain/entities/energy_entity.dart';
import 'package:vocabu_rex_mobile/energy/domain/entities/buy_energy_entity.dart';
import 'package:vocabu_rex_mobile/energy/domain/usecases/get_energy_status_usecase.dart';
import 'package:vocabu_rex_mobile/energy/domain/usecases/buy_energy_usecase.dart';

// Events
abstract class EnergyEvent {}
class GetEnergyStatusEvent extends EnergyEvent {
  final bool? includeTransactionHistory;
  final int? historyLimit;
  GetEnergyStatusEvent({this.includeTransactionHistory, this.historyLimit});
}

class BuyEnergyEvent extends EnergyEvent {
  final int energyAmount;
  final String paymentMethod; // 'GEMS' or 'COINS'
  BuyEnergyEvent({required this.energyAmount, required this.paymentMethod});
}

// States
abstract class EnergyState {}
class EnergyInitial extends EnergyState {}
class EnergyLoading extends EnergyState {}
class EnergyLoaded extends EnergyState {
  final EnergyEntity response;
  EnergyLoaded(this.response);
}
class EnergyError extends EnergyState {
  final String message;
  EnergyError(this.message);
}
class EnergyBuySuccess extends EnergyState {
  final BuyEnergyEntity purchase;
  EnergyBuySuccess(this.purchase);
}
class EnergyBuyError extends EnergyState {
  final String message;
  EnergyBuyError(this.message);
}

// Bloc
class EnergyBloc extends Bloc<EnergyEvent, EnergyState> {
  final GetEnergyStatusUseCase getEnergyStatusUseCase;
  final BuyEnergyUseCase buyEnergyUseCase;

  EnergyBloc({
    required this.getEnergyStatusUseCase,
    required this.buyEnergyUseCase,
  }) : super(EnergyInitial()) {
    on<GetEnergyStatusEvent>(_onGetEnergyStatus);
    on<BuyEnergyEvent>(_onBuyEnergy);
  }

  Future<void> _onGetEnergyStatus(GetEnergyStatusEvent event, Emitter<EnergyState> emit) async {
    emit(EnergyLoading());
    try {
      final response = await getEnergyStatusUseCase.call(
        includeTransactionHistory: event.includeTransactionHistory,
        historyLimit: event.historyLimit,
      );
      emit(EnergyLoaded(response));
    } catch (e) {
      emit(EnergyError(e.toString()));
    }
  }

  Future<void> _onBuyEnergy(BuyEnergyEvent event, Emitter<EnergyState> emit) async {
    emit(EnergyLoading());
    try {
      final purchase = await buyEnergyUseCase.call(
        energyAmount: event.energyAmount,
        paymentMethod: event.paymentMethod,
      );
      if (purchase.success) {
        emit(EnergyBuySuccess(purchase));
        // Refresh energy status after successful purchase
        add(GetEnergyStatusEvent());
      } else {
        emit(EnergyBuyError(purchase.error ?? 'Purchase failed'));
      }
    } catch (e) {
      emit(EnergyBuyError(e.toString()));
    }
  }
}
