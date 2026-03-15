import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/features/groups/domain/entities/group_member_entity.dart';

part 'payer_event.dart';
part 'payer_state.dart';

class PayerBloc extends Bloc<PayerEvent, PayerState> {
  PayerBloc() : super(const PayerState()) {
    on<LoadPayerEvent>(_onLoadPayer);
    on<SelectPayerEvent>(_onSelectPayer);
  }

  void _onLoadPayer(LoadPayerEvent event, Emitter<PayerState> emit) {
    emit(state.copyWith(
      members: event.members,
      selectedPayerId: event.initialPayerId,
    ));
  }

  void _onSelectPayer(SelectPayerEvent event, Emitter<PayerState> emit) {
    emit(state.copyWith(selectedPayerId: event.payerId));
  }
}
