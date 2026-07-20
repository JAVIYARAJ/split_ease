import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:split_ease/features/expenses/domain/entities/expense_detail_entity.dart';

abstract class ExpenseDetailState extends Equatable {
  final bool hasChanges;
  const ExpenseDetailState({this.hasChanges = false});

  @override
  List<Object?> get props => [hasChanges];
}

class ExpenseDetailInitial extends ExpenseDetailState {}

class ExpenseDetailLoading extends ExpenseDetailState {
  const ExpenseDetailLoading({super.hasChanges});
}

class ExpenseDetailLoaded extends ExpenseDetailState {
  final ExpenseDetailEntity expenseDetail;
  final String currentUserId;
  final String? currentUserRole;
  final List<ExpenseCommentEntity> comments;
  final bool commentsLoading;
  final String? editingCommentId;
  final String? editingCommentText;

  const ExpenseDetailLoaded(
    this.expenseDetail, 
    this.currentUserId, 
    {
      this.currentUserRole, 
      this.comments = const [],
      this.commentsLoading = false,
      this.editingCommentId,
      this.editingCommentText,
      super.hasChanges,
    }
  );

  /// Logic Moved from UI: Gets first name of the creator.
  String get creatorFirstName => expenseDetail.createdBy.fullName.split(' ').first;

  /// Logic Moved from UI: Gets display name for the group.
  String get groupDisplayName => (expenseDetail.group?.name ?? "").isNotEmpty ? expenseDetail.group!.name! : "Non-group expense";

  /// Logic Moved from UI: Gets first name of the editor if updated.
  String? get updatedByFirstName => expenseDetail.updatedBy?.fullName.split(' ').first;

  /// Status of the expense
  bool get isDeleted => expenseDetail.isDeleted;

  /// Logic Moved from UI: Gets formatted updated timestamp.
  String? get formattedUpdatedAt {
    if (expenseDetail.updatedAt == null) return null;
    try {
      final parsed = DateTime.parse(expenseDetail.updatedAt!);
      // For updated time, show more detail (hh:mm a)
      return DateFormat('MMM dd, yyyy \u2022 hh:mm a').format(parsed);
    } catch (_) {
      return null;
    }
  }

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
    List<ExpenseCommentEntity>? comments,
    bool? commentsLoading,
    String? editingCommentId,
    String? editingCommentText,
    bool clearEditing = false,
    bool? hasChanges,
  }) {
    return ExpenseDetailLoaded(
      expenseDetail ?? this.expenseDetail,
      currentUserId ?? this.currentUserId,
      currentUserRole: currentUserRole ?? this.currentUserRole,
      comments: comments ?? this.comments,
      commentsLoading: commentsLoading ?? this.commentsLoading,
      editingCommentId: clearEditing ? null : (editingCommentId ?? this.editingCommentId),
      editingCommentText: clearEditing ? null : (editingCommentText ?? this.editingCommentText),
      hasChanges: hasChanges ?? this.hasChanges,
    );
  }

  @override
  List<Object?> get props => [
    expenseDetail, 
    currentUserId, 
    currentUserRole, 
    comments, 
    commentsLoading, 
    editingCommentId,
    editingCommentText,
    hasChanges
  ];
}

class ExpenseDetailError extends ExpenseDetailState {
  final String message;

  const ExpenseDetailError(this.message, {super.hasChanges});

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

class ExpenseRestoreLoading extends ExpenseDetailState {}

class ExpenseRestored extends ExpenseDetailState {
  final String expenseId;
  const ExpenseRestored(this.expenseId) : super(hasChanges: true);

  @override
  List<Object?> get props => [expenseId, hasChanges];
}

class ExpenseRestoreError extends ExpenseDetailState {
  final String message;

  const ExpenseRestoreError(this.message);

  @override
  List<Object?> get props => [message, hasChanges];
}

/// Emitted when a comment add/update/delete RPC call fails.
/// The loaded state is preserved; the UI listens and shows a snackbar.
class CommentActionError extends ExpenseDetailState {
  final String message;
  final ExpenseDetailLoaded previousState;

  const CommentActionError(this.message, this.previousState);

  @override
  List<Object?> get props => [message, previousState];
}
