import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'package:split_ease/features/auth/domain/usecases/user_sign_up.dart';
import '../../../../../core/common/cubit/app_user_cubit.dart';

part 'register_event.dart';

part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final UserSignUp userSignUp;
  final GoogleSignInUseCase _googleSignInUseCase;
  final AppUserCubit _appUserCubit;

  RegisterBloc(this.userSignUp, this._googleSignInUseCase, this._appUserCubit) : super(RegisterInitial()) {
    on<RegisterUser>((event, emit) async {
      emit(RegisterLoading());
      var response = await userSignUp(UserSignUpParam(event.email, event.name, event.password));
      response.fold(
        (l) {
          emit(RegisterFailure(l.message));
        },
        (r) {
          _appUserCubit.updateUser(r);
          emit(RegisterSuccess("Register successfully"));
        },
      );
    });

    on<GoogleSignInRequested>((event, emit) async {
      emit(RegisterGoogleLoading());
      final response = await _googleSignInUseCase(NoParams());
      response.fold(
        (l) => emit(RegisterFailure(l.message)),
        (user) {
          if (user == null) {
            emit(RegisterInitial());
            return;
          }
          _appUserCubit.updateUser(user);
          emit(RegisterGoogleSuccess("Signed in with Google"));
        },
      );
    });
  }
}
