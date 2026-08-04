import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/common/cubit/app_user_cubit.dart';
import 'package:split_ease/features/account/domain/usecases/account_logout.dart';
import 'package:split_ease/core/enums/app_enums.dart';
export 'package:split_ease/core/enums/app_enums.dart';

import '../../../../core/usecases/use_case.dart';
part 'account_event.dart';

part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AccountLogout accountLogout;

  final AppUserCubit _appUserCubit;

  AccountBloc({
    required this.accountLogout,
    required AppUserCubit appUserCubit,
  }) : _appUserCubit = appUserCubit,
        super(AccountState()) {
    on<AccountLogoutEvent>((event, emit) async {
      try {
        emit(state.copyWith(status: AccountStatus.loading));
        var response = await accountLogout(NoParams());
        response.fold(
          (l) {
            emit(state.copyWith(status: AccountStatus.failure, message: l.message));
          },
          (r) {
            _appUserCubit.updateUser(null);
            emit(state.copyWith(status: AccountStatus.success, message: "Logout successfully."));
          },
        );
      } catch (error) {
        emit(state.copyWith(status: AccountStatus.failure, message: error.toString()));
      }
    });

  }
}
