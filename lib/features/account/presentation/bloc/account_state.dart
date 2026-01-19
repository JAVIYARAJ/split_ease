part of 'account_bloc.dart';

enum AccountStatus { initial, loading, success, failure }



class AccountState {
  final AccountStatus status;
  final String message;

  const AccountState({this.status = AccountStatus.initial, this.message = ''});

  AccountState copyWith({AccountStatus? status, String? message}) {
    return AccountState(status: status ?? this.status, message: message ?? this.message);
  }
}
