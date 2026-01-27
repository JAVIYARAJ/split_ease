import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart'; // Add this import
import 'package:split_ease/features/account/domain/usecases/account_logout.dart';
import 'package:split_ease/features/account/domain/usecases/upload_profile_picture.dart';
import '../../../../core/common/cubit/app_user_cubit.dart';
import '../../../../core/services/image_picker_service.dart';

part 'account_event.dart';

part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AccountLogout accountLogout;
  final UploadProfilePicture uploadProfilePicture;
  final ImagePickerService imagePickerService;
  final AppUserCubit _appUserCubit;

  AccountBloc({
    required this.accountLogout,
    required this.uploadProfilePicture,
    required this.imagePickerService,
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

    on<AccountImagePicked>((event, emit) async {
      try {
        final File? image = await imagePickerService.pickImage(source: event.source);
        if (image != null) {
          emit(state.copyWith(status: AccountStatus.loading));
          final response = await uploadProfilePicture(image);
          response.fold(
            (failure) => emit(state.copyWith(status: AccountStatus.failure, message: failure.message)),
            (url) {
              // Update global user state with new avatar URL
              final currentUser = _appUserCubit.state is AppUserLoggedIn
                  ? (_appUserCubit.state as AppUserLoggedIn).user
                  : null;
              
              if (currentUser != null) {
                 final updatedUser = currentUser.copyWith(avatarUrl: url); // Assuming copyWith exists
                 _appUserCubit.updateUser(updatedUser);
              }
              emit(state.copyWith(status: AccountStatus.profileUpdated, message: "Profile picture updated!"));
            },
          );
        }
      } catch (e) {
        emit(state.copyWith(status: AccountStatus.failure, message: e.toString()));
      }
    });

  }
}
