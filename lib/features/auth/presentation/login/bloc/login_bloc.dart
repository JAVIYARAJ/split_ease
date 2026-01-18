import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/features/auth/domain/usecases/user_login.dart';

part 'login_event.dart';

part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserLogin userLogin;

  LoginBloc(this.userLogin) : super(const LoginState()) {
    on<LoginUser>((event, emit) async {
      emit(state.copyWith(status: LoginStatus.loading));
      var response = await userLogin(UserLoginParam(email: event.email, password: event.password));
      await response.fold(
        (l) {
          emit(state.copyWith(status: LoginStatus.failure, message: l.message));
        },
        (r) async {
          emit(state.copyWith(status: LoginStatus.success, message: "Login successfully"));
        },
      );
    });
  }
}
