import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/features/groups/domain/usecases/get_all_groups.dart';

import '../../../../core/usecases/use_case.dart';
import '../../domain/entities/group_entity.dart';
import 'package:split_ease/core/enums/app_enums.dart';
export 'package:split_ease/core/enums/app_enums.dart';

part 'groups_event.dart';

part 'groups_state.dart';

class GroupsBloc extends Bloc<GroupsEvent, GroupsState> {
  final GetAllGroups getAllGroups;

  GroupsBloc({required this.getAllGroups}) : super(const GroupsState()) {
    on<LoadGroups>(_onLoadGroups);
    on<ToggleGroupsFab>((event, emit) => emit(state.copyWith(isFabExtended: event.isExtended)));
  }


  Future<void> _onLoadGroups(LoadGroups event, Emitter<GroupsState> emit) async {
    try {
      emit(state.copyWith(status: GroupsStatus.loading));
      var allGroups = await getAllGroups(NoParams());
      allGroups.fold(
        (l) {
          emit(state.copyWith(status: GroupsStatus.failure, errorMessage: l.message));
        },
        (r) {
          emit(state.copyWith(status: GroupsStatus.success, groups: r));
        },
      );
    } catch (e) {
      emit(state.copyWith(status: GroupsStatus.failure, errorMessage: "Failed to load groups"));
    }
  }
}
