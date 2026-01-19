import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/features/auth/domain/usecases/user_sign_up.dart';
import '../../../../../core/common/cubit/app_user_cubit.dart';

part 'register_event.dart';

part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final UserSignUp userSignUp;
  final AppUserCubit _appUserCubit;

  RegisterBloc(this.userSignUp, this._appUserCubit) : super(RegisterInitial()) {
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
  }
}
