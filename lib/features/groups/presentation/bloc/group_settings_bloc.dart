import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/usecases/get_group_detail.dart';


part 'group_settings_event.dart';
part 'group_settings_state.dart';

class GroupSettingsBloc extends Bloc<GroupSettingsEvent, GroupSettingsState> {
  final GetGroupDetail getGroupDetail;
  GroupSettingsBloc({
    required this.getGroupDetail,
  }) : super(GroupSettingsInitial()) {
    on<LoadGroupSettings>(_onLoadGroupSettings);
    on<LeaveGroupEvent>(_onLeaveGroup);
    on<DeleteGroupEvent>(_onDeleteGroup);
  }

  void _onLoadGroupSettings(LoadGroupSettings event, Emitter<GroupSettingsState> emit) async {
    emit(GroupSettingsLoading());
    final result = await getGroupDetail(GroupDetailParam(event.groupId));
    result.fold(
      (failure) => emit(GroupSettingsError(failure.message)),
      (group) => emit(GroupSettingsLoaded(group)),
    );
  }

  void _onLeaveGroup(LeaveGroupEvent event, Emitter<GroupSettingsState> emit) async {
    // emit(GroupSettingsLoading());
    // final result = await leaveGroup(event.groupId);
    // result.fold(
    //   (failure) => emit(GroupSettingsError(failure.message)),
    //   (success) => emit(GroupActionSuccess("Left group successfully")),
    // );
  }

  void _onDeleteGroup(DeleteGroupEvent event, Emitter<GroupSettingsState> emit) async {
    // emit(GroupSettingsLoading());
    // final result = await deleteGroup(event.groupId);
    // result.fold(
    //   (failure) => emit(GroupSettingsError(failure.message)),
    //   (success) => emit(GroupActionSuccess("Deleted group successfully")),
    // );
  }
}
