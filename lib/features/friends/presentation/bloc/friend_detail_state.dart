import 'package:equatable/equatable.dart';
import 'package:split_ease/core/enums/app_enums.dart';
export 'package:split_ease/core/enums/app_enums.dart';
import 'package:split_ease/features/friends/domain/entities/friend_entity.dart';
import 'package:split_ease/features/friends/domain/entities/friend_expense_history_entity.dart';

class FriendDetailState extends Equatable {
  final FriendEntity? friendEntity;
  final bool hasChanges;
  
  final FriendDetailExpenseStatus expenseStatus;
  final FriendExpenseHistoryEntity? expenseHistory;
  final String? expenseErrorMessage;

  const FriendDetailState({
    this.friendEntity,
    this.hasChanges = false,
    this.expenseStatus = FriendDetailExpenseStatus.initial,
    this.expenseHistory,
    this.expenseErrorMessage,
  });

  FriendDetailState copyWith({
    FriendEntity? friendEntity,
    bool? hasChanges,
    FriendDetailExpenseStatus? expenseStatus,
    FriendExpenseHistoryEntity? expenseHistory,
    String? expenseErrorMessage,
  }) {
    return FriendDetailState(
      friendEntity: friendEntity ?? this.friendEntity,
      hasChanges: hasChanges ?? this.hasChanges,
      expenseStatus: expenseStatus ?? this.expenseStatus,
      expenseHistory: expenseHistory ?? this.expenseHistory,
      expenseErrorMessage: expenseErrorMessage ?? this.expenseErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
        friendEntity,
        hasChanges,
        expenseStatus,
        expenseHistory,
        expenseErrorMessage,
      ];
}
