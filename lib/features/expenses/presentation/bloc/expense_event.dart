part of 'expense_bloc.dart';

sealed class ExpenseEvent {
  const ExpenseEvent();
}

class ExpenseInitialized extends ExpenseEvent {
  final GroupEntity? group;
  final FriendEntity? friend;
  final String? currentUserId;
  final ExpenseOrigin origin;
  final String? lastUsedCategoryId;
  const ExpenseInitialized({
    this.group,
    this.friend,
    this.currentUserId,
    this.origin = ExpenseOrigin.global,
    this.lastUsedCategoryId,
  });
}

class ExpenseEditInitialized extends ExpenseEvent {
  final ExpenseDetailEntity expense;
  final String currentUserId;
  const ExpenseEditInitialized({required this.expense, required this.currentUserId});
}


class GroupChanged extends ExpenseEvent {
  final GroupEntity? group;
  const GroupChanged(this.group);
}

class AmountChanged extends ExpenseEvent {
  final String amount;
  const AmountChanged(this.amount);


}

class DescriptionChanged extends ExpenseEvent {
  final String description;
  const DescriptionChanged(this.description);


}

class PayerChanged extends ExpenseEvent {
  final String userId;
  const PayerChanged(this.userId);


}

class DateChanged extends ExpenseEvent {
  final DateTime date;
  const DateChanged(this.date);


}

class SplitTypeChanged extends ExpenseEvent {
  final SplitType splitType;
  const SplitTypeChanged(this.splitType);


}

class SplitOptionChanged extends ExpenseEvent {
  final List<ExpenseSplit> splits;
  const SplitOptionChanged(this.splits);
  

}


class ValidateNavigation extends ExpenseEvent {
  final Function() onValid;
  const ValidateNavigation({required this.onValid});
}

class AddExpenseSubmitted extends ExpenseEvent {
  final String? groupId;
  const AddExpenseSubmitted({this.groupId});
}

class FetchGroupMembers extends ExpenseEvent {
  final String groupId;
  const FetchGroupMembers(this.groupId);
}

class FetchParticipants extends ExpenseEvent {
  final String? groupId;
  final String? friendUserId;
  const FetchParticipants({this.groupId, this.friendUserId});
}

class FetchCommonGroups extends ExpenseEvent {
  final List<String> userIds;
  const FetchCommonGroups(this.userIds);
}
class NotesChanged extends ExpenseEvent {
  final String notes;
  const NotesChanged(this.notes);
}

class FetchCategories extends ExpenseEvent {
  final String? lastUsedCategoryId;
  const FetchCategories({this.lastUsedCategoryId});
}

class CategoryChanged extends ExpenseEvent {
  final ExpenseCategoryEntity category;
  const CategoryChanged(this.category);
}

class PaymentMethodChanged extends ExpenseEvent {
  final ExpensePaymentMethodEntity paymentMethod;
  const PaymentMethodChanged(this.paymentMethod);
}

class ExpenseOriginChanged extends ExpenseEvent {
  final ExpenseOrigin origin;
  const ExpenseOriginChanged(this.origin);
}

class FetchAllFriendsForGlobalMode extends ExpenseEvent {
  const FetchAllFriendsForGlobalMode();
}

class AttachmentsChanged extends ExpenseEvent {
  final List<String> attachments; // We can store File paths as Strings to avoid dragging dart:io into event definitions unnecessarily, or just import dart:io
  const AttachmentsChanged(this.attachments);
}
