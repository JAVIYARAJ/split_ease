part of 'expense_bloc.dart';

/// Represents the status of the expense creation process.
enum ExpenseStatus { initial, loading, success, failure, validationError }

class ExpenseState {
  final ExpenseStatus status;
  final ExpenseStatus groupMembersStatus; // New status for member fetching
  final GroupEntity? group;
  final FriendEntity? friend;
  final String amount;
  final String description;
  final String? payerId; // ID of the user who paid
  final String? currentUserId; // ID of the user creating the expense
  final String? expenseId; // ID of the expense if editing
  final bool isEdit;
  final DateTime? date;
  final SplitType splitType;
  final List<ExpenseSplit> splits;
  final List<GroupMemberEntity> groupMembers;
  final List<GroupEntity> commonGroups;
  final List<ExpenseCategoryEntity> categories;
  final ExpenseCategoryEntity? selectedCategory;
  final ExpenseOrigin origin;
  final String notes;
  final String? errorMessage;


  const ExpenseState({
    this.status = ExpenseStatus.initial,
    this.groupMembersStatus = ExpenseStatus.initial,
    this.group,
    this.friend,
    this.amount = '',
    this.description = '',
    this.payerId,
    this.currentUserId,
    this.expenseId,
    this.isEdit = false,
    this.date,
    this.splitType = SplitType.equal,
    this.splits = const [],
    this.groupMembers = const [],
    this.commonGroups = const [],
    this.categories = const [],
    this.selectedCategory,
    this.origin = ExpenseOrigin.global,
    this.notes = '',
    this.errorMessage,
  });


  /// Logic Moved from UI: Gets the display name of the payer.
  String? get payerName {
    if (payerId == null) {
      return "you"; // Or explicitly "Select payer" if we want to force selection
    }
    
    // Check if the payer is the current user
    if (payerId == currentUserId) return "you";

    if (groupMembers.isEmpty) return "you";

    try {
      return groupMembers.firstWhere((m) => m.userId == payerId).fullName;
    } catch (_) {
      return "you";
    }
  }


  /// Logic Moved from UI: Checks if navigation to payer/split selection is allowed.
  bool get isBaseInfoValid => description.isNotEmpty && 
                             amount.isNotEmpty && 
                             (double.tryParse(amount) ?? 0) > 0;

  /// Logic Moved from UI: Detailed validation message for basic info.
  String? get baseInfoValidationError {
    if (description.isEmpty) return "Please enter a description first";
    if (amount.isEmpty || (double.tryParse(amount) ?? 0) <= 0) return "Please enter a valid amount first";
    return null;
  }

  /// Logic Moved from UI: Gets a human-readable description of how the expense is split.
  String get splitDescription {
    if (splitType == SplitType.equal) {
       if (splits.length == groupMembers.length) return "equally";
       return "equally (${splits.length})";
    }
    return "unequally";
  }

  ExpenseState copyWith({
    ExpenseStatus? status,
    ExpenseStatus? groupMembersStatus,
    GroupEntity? Function()? group,
    FriendEntity? Function()? friend,
    String? amount,
    String? description,
    String? Function()? payerId,
    String? currentUserId,
    String? Function()? expenseId,
    bool? isEdit,
    DateTime? date,
    SplitType? splitType,
    List<ExpenseSplit>? splits,
    List<GroupMemberEntity>? groupMembers,
    List<GroupEntity>? commonGroups,
    List<ExpenseCategoryEntity>? categories,
    ExpenseCategoryEntity? Function()? selectedCategory,
    ExpenseOrigin? origin,
    String? notes,
    String? Function()? errorMessage,
  }) {
    return ExpenseState(
      status: status ?? this.status,
      groupMembersStatus: groupMembersStatus ?? this.groupMembersStatus,
      group: group != null ? group() : this.group,
      friend: friend != null ? friend() : this.friend,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      payerId: payerId != null ? payerId() : this.payerId,
      currentUserId: currentUserId ?? this.currentUserId,
      expenseId: expenseId != null ? expenseId() : this.expenseId,
      isEdit: isEdit ?? this.isEdit,
      date: date ?? this.date,
      splitType: splitType ?? this.splitType,
      splits: splits ?? this.splits,
      groupMembers: groupMembers ?? this.groupMembers,
      commonGroups: commonGroups ?? this.commonGroups,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory != null ? selectedCategory() : this.selectedCategory,
      origin: origin ?? this.origin,
      notes: notes ?? this.notes,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }


  /// Transitions the state to a specific group context.
  ExpenseState toGroupMode(GroupEntity group) {
    return copyWith(
      group: () => group,
      // Friend is preserved
      splits: const [],
      groupMembers: const [],
      groupMembersStatus: ExpenseStatus.loading,
    );
  }

  /// Transitions the state back to a non-group context.
  ExpenseState clearGroup() {
    return copyWith(
      group: () => null,
      splits: const [],
      groupMembers: const [],
      groupMembersStatus: ExpenseStatus.loading,
    );
  }
}
