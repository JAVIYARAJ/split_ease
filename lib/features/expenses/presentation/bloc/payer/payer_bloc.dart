import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/features/groups/domain/entities/group_member_entity.dart';

part 'payer_event.dart';
part 'payer_state.dart';

class PayerBloc extends Bloc<PayerEvent, PayerState> {
  /// Logic Coordinator for the Payer Selection Page.
  /// 
  /// Manages the list of members and tracks the currently selected payer ID.
  PayerBloc() : super(const PayerState()) {
    on<LoadPayerEvent>(_onLoadPayer);
    on<SelectPayerEvent>(_onSelectPayer);
  }

  /// Sets the initial list of members and the current payer ID.
  void _onLoadPayer(LoadPayerEvent event, Emitter<PayerState> emit) {
    emit(state.copyWith(
      members: event.members,
      selectedPayerId: event.initialPayerId,
    ));
  }

  /// Logic Moved from UI: Handles the selection of a new payer.
  void _onSelectPayer(SelectPayerEvent event, Emitter<PayerState> emit) {
    emit(state.copyWith(selectedPayerId: event.payerId));
  }
}
