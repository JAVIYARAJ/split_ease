
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/splash/domain/usecases/user_active_session.dart';
import '../../../../core/common/cubit/app_user_cubit.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final UserActiveSession userActiveSession;
  final AppUserCubit _appUserCubit;

  SplashCubit(this.userActiveSession, this._appUserCubit) : super(SplashInitial());

  /// Starts splash timer
  Future<void> start() async {
    await Future.delayed(const Duration(seconds: 3));
    var response = await userActiveSession(NoParams());
    response.fold(
      (l) {
        emit(SplashNavigateToLogin());
      },
      (activeUser) {
        _appUserCubit.updateUser(activeUser);
        emit(SplashNavigateToHome());
      },
    );
  }
}
