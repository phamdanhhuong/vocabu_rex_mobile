import 'package:bloc/bloc.dart';
import 'package:vocabu_rex_mobile/auth/domain/usecases/register_usercase.dart';

class AuthEvent {}

class RegisterEvent extends AuthEvent {
  String email;
  String password;
  RegisterEvent({required this.email, required this.password});
}

class AuthState {}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUsercase registerUsercase;
  AuthBloc({required this.registerUsercase}) : super(AuthState()) {
    on<RegisterEvent>((event, emit) async {
      await registerUsercase(event.email, event.password);
    });
  }
}
