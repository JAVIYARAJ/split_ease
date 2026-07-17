import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/core/services/data_refresh_service.dart';
import 'package:split_ease/features/expenses/domain/usecases/settle_up_usecase.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_detail_entity.dart';
import 'package:split_ease/features/expenses/domain/usecases/get_expense_metadata_usecase.dart';
import 'package:split_ease/features/groups/domain/entities/group_entity.dart';
import 'package:split_ease/features/groups/domain/usecases/get_common_groups_usecase.dart';

part 'settle_up_state.dart';

class SettleUpCubit extends Cubit<SettleUpState> {
  final SettleUpUseCase settleUpUseCase;
  final GetCommonGroupsUseCase getCommonGroupsUseCase;
  final GetExpenseMetadataUseCase getExpenseMetadataUseCase;
  final DataRefreshCubit dataRefreshCubit;

  SettleUpCubit({
    required this.settleUpUseCase,
    required this.getCommonGroupsUseCase,
    required this.getExpenseMetadataUseCase,
    required this.dataRefreshCubit,
  }) : super(SettleUpState());

  void initialize({
    required String currentUserId,
    String? groupId,
    String? targetUserId,
    double? initialAmount,
  }) async {
    emit(state.copyWith(
      currentUserId: currentUserId,
      targetUserId: targetUserId,
      groupId: groupId,
      amount: initialAmount?.abs().toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '') ?? '0',
      targetBalance: initialAmount?.abs() ?? 0,
    ));

    if (targetUserId != null) {
      final groupsResult = await getCommonGroupsUseCase([currentUserId, targetUserId]);
      groupsResult.fold(
        (_) => null,
        (groups) {
          emit(state.copyWith(commonGroups: groups));
        },
      );
    }

    final metadataResult = await getExpenseMetadataUseCase();
    metadataResult.fold(
      (_) => null,
      (metadata) {
        ExpensePaymentMethodEntity? cashMethod;
        for (var m in metadata.paymentMethods) {
          if (m.name.toLowerCase() == 'cash') {
            cashMethod = m;
            break;
          }
        }
        cashMethod ??= metadata.paymentMethods.first;
        emit(state.copyWith(
          paymentMethods: metadata.paymentMethods,
          selectedPaymentMethodId: cashMethod.id,
        ));
      },
    );
  }

  void onAmountChanged(String amount) {
    emit(state.copyWith(amount: amount));
  }

  void onDateChanged(DateTime date) {
    emit(state.copyWith(date: date));
  }

  void onNoteChanged(String note) {
    emit(state.copyWith(note: note));
  }

  void onGroupChanged(String? groupId) {
    if (groupId == null) {
      emit(state.copyWith(clearGroupId: true));
    } else {
      emit(state.copyWith(groupId: groupId));
    }
  }

  void onPaymentMethodChanged(String paymentMethodId) {
    emit(state.copyWith(selectedPaymentMethodId: paymentMethodId));
  }

  Future<void> submitPayment() async {
    final double? amt = double.tryParse(state.amount);
    if (amt == null || amt <= 0) {
      emit(state.copyWith(status: SettleUpStatus.failure, errorMessage: "Please enter a valid amount"));
      return;
    }

    if (state.targetUserId == null) {
      emit(state.copyWith(status: SettleUpStatus.failure, errorMessage: "Target user is required"));
      return;
    }

    emit(state.copyWith(status: SettleUpStatus.loading));

    final params = SettleUpParams(
      toUserId: state.targetUserId!,
      amount: amt,
      groupId: state.groupId,
      note: state.note.isEmpty ? "Settlement" : state.note,
      paymentMethodId: state.selectedPaymentMethodId,
    );

    final result = await settleUpUseCase(params);

    result.fold(
      (failure) => emit(state.copyWith(status: SettleUpStatus.failure, errorMessage: failure.message)),
      (_) {
        dataRefreshCubit.markMultipleForRefresh([
          RefreshType.home,
          RefreshType.groups,
          RefreshType.friends,
          RefreshType.activity,
        ]);
        if (state.groupId != null) {
          dataRefreshCubit.markForRefresh(RefreshType.groupDetail, id: state.groupId);
        }
        if (state.targetUserId != null) {
          dataRefreshCubit.markForRefresh(RefreshType.friendDetail, id: state.targetUserId);
        }

        emit(state.copyWith(status: SettleUpStatus.success));
      },
    );
  }
}
