import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/core/usecases/use_case.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_detail_entity.dart';
import 'package:split_ease/features/expenses/domain/repositories/expense_repository.dart';

class GetExpenseParticipantsUsecase implements UseCase<List<ExpenseUserEntity>, GetExpenseParticipantsParams> {
  final ExpenseRepository repository;

  GetExpenseParticipantsUsecase({required this.repository});

  @override
  Future<Either<Failure, List<ExpenseUserEntity>>> call(GetExpenseParticipantsParams params) async {
    return await repository.getExpenseParticipants(
      groupId: params.groupId,
      friendUserId: params.friendUserId,
    );
  }
}

class GetExpenseParticipantsParams extends Equatable {
  final String? groupId;
  final String? friendUserId;

  const GetExpenseParticipantsParams({this.groupId, this.friendUserId});

  @override
  List<Object?> get props => [groupId, friendUserId];
}
