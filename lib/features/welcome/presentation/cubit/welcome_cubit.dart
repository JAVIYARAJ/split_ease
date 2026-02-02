
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/core/domain/usecases/set_first_time_user_seen.dart';

part 'welcome_state.dart';

class WelcomeCubit extends Cubit<WelcomeState> {
  final SetFirstTimeUserSeen setFirstTimeUserSeen;

  WelcomeCubit(this.setFirstTimeUserSeen) : super(WelcomeInitial());

  Future<void> navigateToAuth() async {
    await setFirstTimeUserSeen();
    emit(WelcomeNavigateToAuth());
  }
}
