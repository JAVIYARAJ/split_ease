import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/expenses/domain/repositories/expense_repository.dart';

class SettleUpParams {
  final String toUserId;
  final double amount;
  final String? groupId;
  final String? note;
  final String? paymentMethodId;
  final DateTime? date;

  SettleUpParams({
    required this.toUserId,
    required this.amount,
    this.groupId,
    this.note,
    this.paymentMethodId,
    this.date,
  });
}

class SettleUpUseCase implements UseCase<void, SettleUpParams> {
  final ExpenseRepository repository;

  SettleUpUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SettleUpParams params) async {
    return await repository.settleUp(
      toUserId: params.toUserId,
      amount: params.amount,
      groupId: params.groupId,
      note: params.note,
      paymentMethodId: params.paymentMethodId,
      date: params.date,
    );
  }
}
