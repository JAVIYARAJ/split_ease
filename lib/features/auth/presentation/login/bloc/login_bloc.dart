import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'package:split_ease/features/auth/domain/usecases/resend_confirmation_email.dart';
import 'package:split_ease/features/auth/domain/usecases/user_login.dart';
import '../../../../../core/common/cubit/app_user_cubit.dart';
import 'package:split_ease/core/enums/app_enums.dart';
export 'package:split_ease/core/enums/app_enums.dart';

part 'login_event.dart';

part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserLogin userLogin;
  final ResendConfirmationEmail _resendConfirmationEmail;
  final GoogleSignInUseCase _googleSignInUseCase;
  final AppUserCubit _appUserCubit;

  LoginBloc({
    required this.userLogin,
    required ResendConfirmationEmail resendConfirmationEmail,
    required GoogleSignInUseCase googleSignInUseCase,
    required AppUserCubit appUserCubit,
  })  : _resendConfirmationEmail = resendConfirmationEmail,
        _googleSignInUseCase = googleSignInUseCase,
        _appUserCubit = appUserCubit,
        super(const LoginState()) {
    on<LoginUser>((event, emit) async {
      emit(state.copyWith(status: LoginStatus.loading));
      var response = await userLogin(UserLoginParam(email: event.email, password: event.password));
      await response.fold(
        (l) {
          emit(state.copyWith(status: LoginStatus.failure, message: l.message));
        },
        (r) async {
          _appUserCubit.updateUser(r);
          emit(state.copyWith(status: LoginStatus.success, message: "Login successfully"));
        },
      );
    });

    on<ResendEmail>((event, emit) async {
      emit(state.copyWith(status: LoginStatus.resendLoading));
      var response = await _resendConfirmationEmail(event.email);
      response.fold(
        (l) => emit(state.copyWith(status: LoginStatus.failure, message: l.message)),
        (r) => emit(state.copyWith(status: LoginStatus.resendSuccess, message: "Verification email sent successfully")),
      );
    });

    on<GoogleSignInRequested>((event, emit) async {
      emit(state.copyWith(status: LoginStatus.googleLoading));
      final response = await _googleSignInUseCase(NoParams());
      response.fold(
        (l) => emit(state.copyWith(status: LoginStatus.failure, message: l.message)),
        (user) {
          if (user == null) {
            emit(state.copyWith(status: LoginStatus.initial));
            return;
          }
          _appUserCubit.updateUser(user);
          emit(state.copyWith(status: LoginStatus.success, message: "Login successfully"));
        },
      );
    });
  }
}
