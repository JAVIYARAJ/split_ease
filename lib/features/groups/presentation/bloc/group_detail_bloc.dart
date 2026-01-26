import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:split_ease/features/groups/domain/entities/group_entity.dart';
import 'package:split_ease/features/groups/domain/usecases/get_group_detail.dart';

part 'group_detail_event.dart';

part 'group_detail_state.dart';

class GroupDetailBloc extends Bloc<GroupDetailEvent, GroupDetailState> {
  final GetGroupDetail getGroupDetail;

  GroupDetailBloc({required this.getGroupDetail}) : super(const GroupDetailState()) {
    on<LoadGroupDetails>(_onLoadGroupDetails);
  }

  Future<void> _onLoadGroupDetails(LoadGroupDetails event, Emitter<GroupDetailState> emit) async {
    emit(state.copyWith(status: GroupDetailStatus.loading));
    try {
      var response = await getGroupDetail(GroupDetailParam(event.groupId));
      response.fold(
        (l) {
          emit(state.copyWith(status: GroupDetailStatus.failure, errorMessage: l.message));
        },
        (r) {
          emit(state.copyWith(status: GroupDetailStatus.success, groupEntity: r));
        },
      );
      emit(state.copyWith(status: GroupDetailStatus.success));
    } catch (e) {
      emit(state.copyWith(status: GroupDetailStatus.failure, errorMessage: e.toString()));
    }
  }
}
