part of 'login_bloc.dart';

enum LoginStatus { initial, loading, success, failure, registerNavigation }

class LoginState {
  final LoginStatus status;
  final String message;
  
  const LoginState({
    this.status = LoginStatus.initial,
    this.message = '',
  });

  LoginState copyWith({
    LoginStatus? status,
    String? message,
  }) {
    return LoginState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}