import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:split_ease/features/groups/domain/entities/group_member_entity.dart';
import 'package:split_ease/features/groups/domain/usecases/get_group_members.dart';
import 'package:split_ease/features/friends/domain/entities/friend_entity.dart';
import 'package:split_ease/features/groups/domain/entities/group_entity.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_entity.dart';
import '../../domain/usecases/add_expense_usecase.dart';
import '../../domain/usecases/create_expense_params.dart';

part 'expense_event.dart';
part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final AddExpenseUseCase addExpenseUseCase;
  final GetGroupMembers getGroupMembers;

  ExpenseBloc({
    required this.addExpenseUseCase,
    required this.getGroupMembers,
  }) : super(const ExpenseState()) {
    on<ExpenseInitialized>(_onInitialized);
    on<GroupChanged>(_onGroupChanged);
    on<FetchGroupMembers>(_onFetchGroupMembers);
    on<AmountChanged>(_onAmountChanged);
    on<DescriptionChanged>(_onDescriptionChanged);
    on<PayerChanged>(_onPayerChanged);
    on<DateChanged>(_onDateChanged);
    on<SplitTypeChanged>(_onSplitTypeChanged);
    on<SplitOptionChanged>(_onSplitOptionChanged);
    on<AddExpenseSubmitted>(_onAddExpenseSubmitted);
  }

  void _onInitialized(ExpenseInitialized event, Emitter<ExpenseState> emit) {
    emit(ExpenseState(
      group: event.group,
      friend: event.friend,
      availableGroups: event.availableGroups,
      payerId: event.currentUserId,
      date: DateTime.now(),
    ));

    if (event.group?.id != null) {
      add(FetchGroupMembers(event.group!.id!));
    }
  }

  void _onGroupChanged(GroupChanged event, Emitter<ExpenseState> emit) {
    emit(state.copyWith(group: event.group));
    if (event.group.id != null) {
      add(FetchGroupMembers(event.group.id!));
    }
  }

  Future<void> _onFetchGroupMembers(FetchGroupMembers event, Emitter<ExpenseState> emit) async {
    emit(state.copyWith(groupMembersStatus: ExpenseStatus.loading));
    final result = await getGroupMembers(event.groupId);
    result.fold(
      (failure) => emit(state.copyWith(
        groupMembersStatus: ExpenseStatus.failure,
        errorMessage: failure.message,
      )),
      (members) => emit(state.copyWith(
        groupMembersStatus: ExpenseStatus.success,
        groupMembers: members,
      )),
    );
  }

  void _onAmountChanged(AmountChanged event, Emitter<ExpenseState> emit) {
    emit(state.copyWith(amount: event.amount));
  }

  void _onDescriptionChanged(DescriptionChanged event, Emitter<ExpenseState> emit) {
    emit(state.copyWith(description: event.description));
  }

  void _onPayerChanged(PayerChanged event, Emitter<ExpenseState> emit) {
    emit(state.copyWith(payerId: event.userId));
  }

  void _onDateChanged(DateChanged event, Emitter<ExpenseState> emit) {
    emit(state.copyWith(date: event.date));
  }

  void _onSplitTypeChanged(SplitTypeChanged event, Emitter<ExpenseState> emit) {
    emit(state.copyWith(splitType: event.splitType));
  }

  void _onSplitOptionChanged(SplitOptionChanged event, Emitter<ExpenseState> emit) {
    emit(state.copyWith(splits: event.splits));
  }

  Future<void> _onAddExpenseSubmitted(AddExpenseSubmitted event, Emitter<ExpenseState> emit) async {
    emit(state.copyWith(status: ExpenseStatus.loading));
    try {
      if (state.group == null || state.payerId == null) {
        throw Exception("Group or Payer not selected");
      }

      final List<Map<String, dynamic>> rpcSplits = [];

      if (state.splitType == SplitType.equal) {
        for (var split in state.splits) {
          rpcSplits.add({'user_id': split.userId});
        }
      } else if (state.splitType == SplitType.exact) {
        for (var split in state.splits) {
          rpcSplits.add({'user_id': split.userId, 'amount': split.amount});
        }
      } else if (state.splitType == SplitType.percentage) {
        for (var split in state.splits) {
          rpcSplits.add({'user_id': split.userId, 'value': split.percentage});
        }
      } else if (state.splitType == SplitType.shares) {
        for (var split in state.splits) {
          rpcSplits.add({'user_id': split.userId, 'value': split.shares});
        }
      }

      final params = CreateExpenseParams(
        groupId: state.group!.id!,
        description: state.description,
        totalAmount: double.parse(state.amount),
        paidByUserId: state.payerId!,
        expenseDate: state.date!,
        splitType: state.splitType == SplitType.shares ? 'share' : state.splitType.name,
        // "equal", "exact", "percentage", "share"
        splits: rpcSplits,
      );

      final result = await addExpenseUseCase(params);

      result.fold(
        (failure) => emit(state.copyWith(status: ExpenseStatus.failure, errorMessage: failure.message)),
        (_) => emit(state.copyWith(status: ExpenseStatus.success)),
      );
    } catch (e) {
      emit(state.copyWith(status: ExpenseStatus.failure, errorMessage: e.toString()));
    }
  }
}
