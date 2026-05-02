import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/currency/domain/entities/payment_entity.dart';
import 'package:vocabu_rex_mobile/currency/domain/usecases/payment_usecase.dart';

// ─── Events ─────────────────────────────────────────
abstract class PaymentEvent {}

class LoadPaymentPackagesEvent extends PaymentEvent {}

class CreatePaymentEvent extends PaymentEvent {
  final String packageId;
  CreatePaymentEvent(this.packageId);
}

// ─── States ─────────────────────────────────────────
abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

class PaymentPackagesLoading extends PaymentState {}

class PaymentPackagesLoaded extends PaymentState {
  final List<PaymentPackageEntity> packages;
  PaymentPackagesLoaded(this.packages);
}

class PaymentCreating extends PaymentState {
  final List<PaymentPackageEntity> packages; // giữ lại list để UI không bị mất
  PaymentCreating(this.packages);
}

class PaymentCreated extends PaymentState {
  final CreatePaymentResultEntity result;
  final List<PaymentPackageEntity> packages;
  PaymentCreated(this.result, this.packages);
}

class PaymentError extends PaymentState {
  final String message;
  final List<PaymentPackageEntity>? packages;
  PaymentError(this.message, {this.packages});
}

// ─── Bloc ───────────────────────────────────────────
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final GetPaymentPackagesUseCase getPaymentPackagesUseCase;
  final CreatePaymentUseCase createPaymentUseCase;

  List<PaymentPackageEntity> _cachedPackages = [];

  PaymentBloc({
    required this.getPaymentPackagesUseCase,
    required this.createPaymentUseCase,
  }) : super(PaymentInitial()) {
    on<LoadPaymentPackagesEvent>(_onLoadPackages);
    on<CreatePaymentEvent>(_onCreatePayment);
  }

  Future<void> _onLoadPackages(
    LoadPaymentPackagesEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentPackagesLoading());
    try {
      final packages = await getPaymentPackagesUseCase.call();
      _cachedPackages = packages;
      emit(PaymentPackagesLoaded(packages));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> _onCreatePayment(
    CreatePaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentCreating(_cachedPackages));
    try {
      final result = await createPaymentUseCase.call(event.packageId);
      emit(PaymentCreated(result, _cachedPackages));
    } catch (e) {
      emit(PaymentError(e.toString(), packages: _cachedPackages));
    }
  }
}
