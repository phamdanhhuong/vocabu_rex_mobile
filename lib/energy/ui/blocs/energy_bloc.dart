import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/energy/domain/entities/energy_entity.dart';
import 'package:vocabu_rex_mobile/energy/domain/usecases/get_energy_status_usecase.dart';

// Events
abstract class EnergyEvent {}
class GetEnergyStatusEvent extends EnergyEvent {
  final bool? includeTransactionHistory;
  final int? historyLimit;
  GetEnergyStatusEvent({this.includeTransactionHistory, this.historyLimit});
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

// Bloc
class EnergyBloc extends Bloc<EnergyEvent, EnergyState> {
  final GetEnergyStatusUseCase getEnergyStatusUseCase;

  EnergyBloc({required this.getEnergyStatusUseCase}) : super(EnergyInitial()) {
    on<GetEnergyStatusEvent>(_onGetEnergyStatus);
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
}
