import 'package:bloc/bloc.dart';
import 'package:vocabu_rex_mobile/auth/domain/entities/user_entity.dart';
import 'package:vocabu_rex_mobile/auth/domain/usecases/login_usecase.dart';
import 'package:vocabu_rex_mobile/auth/domain/usecases/register_usecase.dart';

// Events
abstract class AuthEvent {}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  RegisterEvent({required this.email, required this.password});
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  LoginEvent({required this.email, required this.password});
}

// States
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserEntity user;
  AuthSuccess({required this.user});
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure({required this.message});
}

class RegisterSuccess extends AuthState {}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUsecase registerUsecase;
  final LoginUsecase loginUsecase;

  AuthBloc({required this.registerUsecase, required this.loginUsecase})
    : super(AuthInitial()) {
    on<RegisterEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await registerUsecase(event.email, event.password);
        emit(RegisterSuccess());
      } catch (e) {
        emit(AuthFailure(message: e.toString()));
      }
    });

    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await loginUsecase(event.email, event.password);
        if (user != null) {
          emit(AuthSuccess(user: user));
        } else {
          emit(AuthFailure(message: 'Đăng nhập thất bại'));
        }
      } catch (e) {
        emit(AuthFailure(message: e.toString()));
      }
    });
  }
}
