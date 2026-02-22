import 'package:fpdart/fpdart.dart';
import 'package:split_ease/core/error/failure.dart';
import 'package:split_ease/features/friends/domain/entities/friend_expense_history_entity.dart';
import 'package:split_ease/features/friends/domain/repository/friends_repository.dart';

import '../../../../core/usecases/use_case.dart';

class GetFriendExpenseHistoryUseCase implements UseCase<FriendExpenseHistoryEntity, GetFriendExpenseHistoryParams> {
  final FriendsRepository repository;

  GetFriendExpenseHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, FriendExpenseHistoryEntity>> call(GetFriendExpenseHistoryParams params) async {
    return await repository.getFriendExpenseHistory(params.friendId);
  }
}

class GetFriendExpenseHistoryParams {
  final String friendId;

  GetFriendExpenseHistoryParams({required this.friendId});
}
