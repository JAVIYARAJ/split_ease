import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:split_ease/features/groups/domain/usecases/join_group.dart';


part 'join_group_event.dart';
part 'join_group_state.dart';

class JoinGroupBloc extends Bloc<JoinGroupEvent, JoinGroupState> {
  final JoinGroup joinGroup;

  JoinGroupBloc({required this.joinGroup}) : super(const JoinGroupState()) {
    on<JoinGroupCodeChanged>(_onCodeChanged);
    on<JoinGroupQrScanned>(_onQrScanned);
    on<JoinGroupSubmitted>(_onSubmitted);
  }

  void _onCodeChanged(JoinGroupCodeChanged event, Emitter<JoinGroupState> emit) {
    emit(state.copyWith(code: event.code, status: JoinGroupStatus.initial));
  }

  Future<void> _onQrScanned(JoinGroupQrScanned event, Emitter<JoinGroupState> emit) async {
    emit(state.copyWith(status: JoinGroupStatus.loading));

    final result = await joinGroup(event.qrCode);

    result.fold(
      (failure) => emit(state.copyWith(
        status: JoinGroupStatus.failure,
        errorMessage: failure.message,
      )),
      (group) => emit(state.copyWith(
        status: JoinGroupStatus.success,
        joinedGroupId: group,
      )),
    );
  }

  Future<void> _onSubmitted(JoinGroupSubmitted event, Emitter<JoinGroupState> emit) async {
    if (!state.isValid) return;

    emit(state.copyWith(status: JoinGroupStatus.loading));

    final result = await joinGroup(state.code);

    result.fold(
      (failure) => emit(state.copyWith(
        status: JoinGroupStatus.failure,
        errorMessage: failure.message,
      )),
      (group) => emit(state.copyWith(
        status: JoinGroupStatus.success,
        joinedGroupId: group,
      )),
    );
  }
}
