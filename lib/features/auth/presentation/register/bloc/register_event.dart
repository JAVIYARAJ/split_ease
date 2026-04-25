part of 'register_bloc.dart';

@immutable
sealed class RegisterEvent {}

final class RegisterUser extends RegisterEvent{
  final String email;
  final String name;
  final String password;

  RegisterUser({required this.email, required this.name, required this.password});

}

final class GoogleSignInRequested extends RegisterEvent {}