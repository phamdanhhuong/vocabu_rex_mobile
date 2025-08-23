import 'package:bloc/bloc.dart';
import 'package:vocabu_rex_mobile/domain/usecases/register_usercase.dart';

class RegisterEvent {
  String email;
  String password;
  RegisterEvent({required this.email, required this.password});
}

class RegisterState {}

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterUsercase registerUsercase;
  RegisterBloc({required this.registerUsercase}) : super(RegisterState()) {
    on<RegisterEvent>((event, emit) async {
      await registerUsercase(event.email, event.password);
    });
  }
}
