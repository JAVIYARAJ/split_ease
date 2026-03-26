import 'package:equatable/equatable.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_detail_entity.dart';

abstract class ExpenseDetailState extends Equatable {
  final bool hasChanges;
  const ExpenseDetailState({this.hasChanges = false});

  @override
  List<Object?> get props => [hasChanges];
}

class ExpenseDetailInitial extends ExpenseDetailState {}

class ExpenseDetailLoading extends ExpenseDetailState {
  const ExpenseDetailLoading({bool hasChanges = false}) : super(hasChanges: hasChanges);
}

class ExpenseDetailLoaded extends ExpenseDetailState {
  final ExpenseDetailEntity expenseDetail;
  final String currentUserId;
  final String? currentUserRole;

  const ExpenseDetailLoaded(this.expenseDetail, this.currentUserId, {this.currentUserRole, bool hasChanges = false}) : super(hasChanges: hasChanges);

  /// Logic Moved from UI: Gets first name of the creator.
  String get creatorFirstName => expenseDetail.createdBy.fullName.split(' ').first;

  /// Logic Moved from UI: Gets display name for the group.
  String get groupDisplayName => (expenseDetail.group?.name ?? "").isNotEmpty ? expenseDetail.group!.name! : "Non-group";

  /// Permission: Can the current user edit or delete this expense?
  bool get canManageExpense {
    // 1. Creator can always delete
    if (currentUserId == expenseDetail.createdBy.id) return true;

    // 2. Owners and Admins in the group can delete any expense
    if (expenseDetail.group?.id != null && currentUserRole != null) {
      return currentUserRole == 'owner' || currentUserRole == 'admin';
    }

    return false;
  }

  ExpenseDetailLoaded copyWith({
    ExpenseDetailEntity? expenseDetail,
    String? currentUserId,
    String? currentUserRole,
    bool? hasChanges,
  }) {
    return ExpenseDetailLoaded(
      expenseDetail ?? this.expenseDetail,
      currentUserId ?? this.currentUserId,
      currentUserRole: currentUserRole ?? this.currentUserRole,
      hasChanges: hasChanges ?? this.hasChanges,
    );
  }

  @override
  List<Object?> get props => [expenseDetail, currentUserId, currentUserRole, hasChanges];
}

class ExpenseDetailError extends ExpenseDetailState {
  final String message;

  const ExpenseDetailError(this.message, {bool hasChanges = false}) : super(hasChanges: hasChanges);

  @override
  List<Object?> get props => [message, hasChanges];
}

class ExpenseDeleteLoading extends ExpenseDetailState {}

class ExpenseDeleted extends ExpenseDetailState {
  const ExpenseDeleted() : super(hasChanges: true);
}

class ExpenseDeleteError extends ExpenseDetailState {
  final String message;

  const ExpenseDeleteError(this.message);

  @override
  List<Object?> get props => [message, hasChanges];
}
