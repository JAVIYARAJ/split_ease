import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/features/groups/domain/usecases/group_create.dart';
import 'package:split_ease/features/groups/domain/usecases/check_invite_code.dart';
import 'package:split_ease/features/groups/domain/usecases/update_group.dart';
import '../../../../../core/services/image_picker_service.dart';
import '../../domain/entities/group_type.dart';
import '../../domain/usecases/group_insert_icon.dart';
import '../../domain/entities/group_entity.dart';
import 'package:split_ease/core/services/data_refresh_service.dart';
import 'dart:math';

part 'create_group_event.dart';

part 'create_group_state.dart';

class CreateGroupBloc extends Bloc<CreateGroupEvent, CreateGroupState> {
  final GroupInsertIcon _groupInsertIcon;
  final ImagePickerService _imagePickerService;
  final GroupCreate _groupCreate;
  final CheckInviteCode _checkInviteCode;
  final UpdateGroup _updateGroup;
  final DataRefreshCubit _dataRefreshCubit;

  CreateGroupBloc(this._imagePickerService, this._groupInsertIcon, this._groupCreate, this._checkInviteCode, this._updateGroup, this._dataRefreshCubit)
    : super(const CreateGroupState()) {
    on<SelectGroupType>(_onSelectGroupType);
    on<PickGroupImage>(_onPickGroupImage);
    on<CreateGroupSubmitted>(_onCreateGroupSubmitted);
    on<GenerateInviteCode>(_onGenerateInviteCode);
    on<InitializeCreateGroup>(_onInitializeCreateGroup);
    on<UpdateGroupSubmitted>(_onUpdateGroupSubmitted);
  }

  Future<void> _onPickGroupImage(PickGroupImage event, Emitter<CreateGroupState> emit) async {
    final file = await _imagePickerService.pickImage();
    if (file != null) {
      emit(state.copyWith(groupImage: file));
    }
  }

  void _onSelectGroupType(SelectGroupType event, Emitter<CreateGroupState> emit) {
    emit(state.copyWith(selectedType: event.type));
  }

  Future<void> _onCreateGroupSubmitted(CreateGroupSubmitted event, Emitter<CreateGroupState> emit) async {
    emit(state.copyWith(status: CreateGroupStatus.loading));
    try {
      if (event.name.isEmpty) {
        emit(state.copyWith(errorMessage: "please enter group name", status: CreateGroupStatus.failure));
      } else {
        //first upload group image
        String? groupPath;
        if (state.groupImage != null) {
          var groupIcon = await _groupInsertIcon(state.groupImage!);
          groupIcon.fold(
            (l) {
              groupPath = null;
            },
            (icon) {
              groupPath = icon;
            },
          );
        }

        var groupResponse = await _groupCreate(
          CreateGroupParam(name: event.name, type: state.selectedType.name, icon: groupPath, inviteCode: state.inviteCode),
        );
        groupResponse.fold(
          (l) {
            emit(state.copyWith(status: CreateGroupStatus.failure, errorMessage: l.message));
          },
          (r) {
            _dataRefreshCubit.markMultipleForRefresh([RefreshType.groups, RefreshType.activity]);
            if (r is List && r.isNotEmpty) {
              emit(state.copyWith(status: CreateGroupStatus.success, createdGroupId: (r as List).firstOrNull?["id"]));
            } else {
              emit(state.copyWith(status: CreateGroupStatus.failure, errorMessage: "Something went wrong"));
            }
          },
        );
      }
    } catch (e) {
      emit(state.copyWith(status: CreateGroupStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onGenerateInviteCode(GenerateInviteCode event, Emitter<CreateGroupState> emit) async {
    emit(state.copyWith(isGeneratingCode: true));

    // Retry logic up to 3 times
    for (int i = 0; i < 3; i++) {
      final code = _generateCode();
      final result = await _checkInviteCode(code);

      bool isUnique = false;
      result.fold(
        (l) => isUnique = false, // If error, assume not unique to be safe or retry? Let's assume retry.
        (r) => isUnique = !r, // if found (r=true), then not unique. if not found (r=false), then unique.
      );

      if (isUnique) {
        emit(state.copyWith(inviteCode: code, isGeneratingCode: false));
        return;
      }
    }

    emit(state.copyWith(isGeneratingCode: false, errorMessage: "Failed to generate a unique invite code. Please try again."));
  }

  String _generateCode({int length = 6}) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();

    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  void _onInitializeCreateGroup(InitializeCreateGroup event, Emitter<CreateGroupState> emit) {
    if (event.group != null) {
      GroupType type;
      try {
        type = GroupType.values.firstWhere((e) => e.name == event.group!.groupType);
      } catch (_) {
        type = GroupType.other;
      }
      emit(
        state.copyWith(
          isEditMode: true,
          selectedType: type,
          existingIconUrl: event.group!.groupIcon,
          inviteCode: event.group!.inviteCode,
          createdGroupId: event.group!.id,
        ),
      );
    }
  }

  Future<void> _onUpdateGroupSubmitted(UpdateGroupSubmitted event, Emitter<CreateGroupState> emit) async {
    emit(state.copyWith(status: CreateGroupStatus.loading));

    try {
      if (event.name.isEmpty) {
        emit(state.copyWith(errorMessage: "please enter group name", status: CreateGroupStatus.failure));
        return;
      }

      String? groupIconUrl = state.existingIconUrl;

      // If a new image is picked, upload it
      if (state.groupImage != null) {
        var groupIconResult = await _groupInsertIcon(state.groupImage!);
        groupIconResult.fold(
          (l) => null, // Handle error optionally
          (icon) => groupIconUrl = icon,
        );
      }

      var result = await _updateGroup(UpdateGroupParam(id: event.groupId, name: event.name, type: event.type.name, icon: groupIconUrl,inviteCode: state.inviteCode));

      result.fold(
        (l) => emit(state.copyWith(status: CreateGroupStatus.failure, errorMessage: l.message)),
        (r) {
          _dataRefreshCubit.markMultipleForRefresh([RefreshType.groups, RefreshType.activity]);
          _dataRefreshCubit.markForRefresh(RefreshType.groupDetail, id: event.groupId);
          emit(state.copyWith(status: CreateGroupStatus.success, createdGroupId: event.groupId));
        },
      );
    } catch (e) {
      emit(state.copyWith(status: CreateGroupStatus.failure, errorMessage: e.toString()));
    }
  }
}
