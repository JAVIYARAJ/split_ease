
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/common/cubit/app_user_cubit.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'package:split_ease/core/enums/app_enums.dart';
export 'package:split_ease/core/enums/app_enums.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UpdateProfileUseCase _updateProfileUseCase;
  final AppUserCubit _appUserCubit;
  final ImagePickerService _imagePickerService;

  ProfileBloc({
    required UpdateProfileUseCase updateProfileUseCase,
    required AppUserCubit appUserCubit,
    required ImagePickerService imagePickerService,
  })  : _updateProfileUseCase = updateProfileUseCase,
        _appUserCubit = appUserCubit,
        _imagePickerService = imagePickerService,
        super(const ProfileState()) {
    on<PickProfileImage>(_onPickProfileImage);
    on<UpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onPickProfileImage(
    PickProfileImage event,
    Emitter<ProfileState> emit,
  ) async {
    final File? image = await _imagePickerService.pickImage(source: event.source);
    if (image != null) {
      emit(state.copyWith(pickedImage: image));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    
    final result = await _updateProfileUseCase(
      UpdateProfileParams(
        name: event.name,
        image: state.pickedImage, // Use image from state
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ProfileStatus.failure, 
        errorMessage: failure.message
      )),
      (user) {
        _appUserCubit.updateUser(user);
        emit(state.copyWith(
          status: ProfileStatus.success, 
          user: user
        ));
      },
    );
  }
}
