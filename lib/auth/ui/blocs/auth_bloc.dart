import 'package:bloc/bloc.dart';
import 'package:vocabu_rex_mobile/auth/domain/entities/user_entity.dart';
import 'package:vocabu_rex_mobile/auth/domain/usecases/login_usecase.dart';
import 'package:vocabu_rex_mobile/auth/domain/usecases/google_login_usecase.dart';
import 'package:vocabu_rex_mobile/auth/domain/usecases/register_usecase.dart';
import 'package:vocabu_rex_mobile/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:vocabu_rex_mobile/core/token_manager.dart';

// Events
abstract class AuthEvent {}

class RegisterEvent extends AuthEvent {
  final Map<String, dynamic> userData;
  RegisterEvent({required this.userData});
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  LoginEvent({required this.email, required this.password});
}

class GoogleLoginEvent extends AuthEvent {
  final String idToken;
  GoogleLoginEvent({required this.idToken});
}

class VerifyOtpEvent extends AuthEvent {
  final String userId;
  final String otp;
  VerifyOtpEvent({required this.userId, required this.otp});
}

class OtpState extends AuthState {
  final String userId;
  OtpState({required this.userId});
}

// States
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class VerifySucess extends AuthState {}

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
  final VerifyOtpUsecase verifyOtpUsecase;
  final GoogleLoginUsecase googleLoginUsecase;

  AuthBloc({
    required this.registerUsecase,
    required this.loginUsecase,
    required this.verifyOtpUsecase,
    required this.googleLoginUsecase,
  }) : super(AuthInitial()) {
    on<RegisterEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final userId = await registerUsecase.call(event.userData);
        emit(OtpState(userId: userId));
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

    on<GoogleLoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await googleLoginUsecase(event.idToken);
        if (user != null) {
          emit(AuthSuccess(user: user));
        } else {
          emit(AuthFailure(message: 'Đăng nhập Google thất bại'));
        }
      } catch (e) {
        emit(AuthFailure(message: e.toString()));
      }
    });

    on<VerifyOtpEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await verifyOtpUsecase(event.userId, event.otp);
        
        // Check if response contains user and tokens (auto-login after verification)
        if (response.containsKey('user') && response.containsKey('tokens')) {
          // Extract user and tokens from response
          final userData = response['user'] as Map<String, dynamic>;
          final tokensData = response['tokens'] as Map<String, dynamic>;
          
          // Save tokens
          await TokenManager.saveLoginInfo(
            accessToken: tokensData['accessToken'] as String,
            refreshToken: tokensData['refreshToken'] as String,
            userId: userData['id'] as String,
            email: userData['email'] as String,
          );
          
          emit(VerifySucess());
        } else {
          emit(VerifySucess());
        }
      } catch (e) {
        emit(AuthFailure(message: e.toString()));
      }
    });
  }
}
