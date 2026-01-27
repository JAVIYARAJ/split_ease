part of 'account_bloc.dart';

@immutable
sealed class AccountEvent {}

class AccountLogoutEvent extends AccountEvent {}

class AccountImagePicked extends AccountEvent {
  final ImageSource source;

  AccountImagePicked(this.source);
}