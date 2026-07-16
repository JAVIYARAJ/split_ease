import 'package:equatable/equatable.dart';

abstract class ExpenseDetailEvent extends Equatable {
  const ExpenseDetailEvent();

  @override
  List<Object> get props => [];
}

class FetchExpenseDetailEvent extends ExpenseDetailEvent {
  final String expenseId;

  const FetchExpenseDetailEvent(this.expenseId);

  @override
  List<Object> get props => [expenseId];
}

class DeleteExpenseEvent extends ExpenseDetailEvent {
  final String expenseId;

  const DeleteExpenseEvent(this.expenseId);

  @override
  List<Object> get props => [expenseId];
}

class RestoreExpenseEvent extends ExpenseDetailEvent {
  final String expenseId;

  const RestoreExpenseEvent(this.expenseId);

  @override
  List<Object> get props => [expenseId];
}

class MarkExpenseAsChanged extends ExpenseDetailEvent {}

class AddExpenseCommentEvent extends ExpenseDetailEvent {
  final String expenseId;
  final String comment;

  const AddExpenseCommentEvent({required this.expenseId, required this.comment});

  @override
  List<Object> get props => [expenseId, comment];
}

class FetchExpenseCommentsEvent extends ExpenseDetailEvent {
  final String expenseId;

  const FetchExpenseCommentsEvent(this.expenseId);

  @override
  List<Object> get props => [expenseId];
}

class UpdateExpenseCommentEvent extends ExpenseDetailEvent {
  final String expenseId;
  final String commentId;
  final String comment;

  const UpdateExpenseCommentEvent({required this.expenseId, required this.commentId, required this.comment});

  @override
  List<Object> get props => [expenseId, commentId, comment];
}

class DeleteExpenseCommentEvent extends ExpenseDetailEvent {
  final String expenseId;
  final String commentId;

  const DeleteExpenseCommentEvent({required this.expenseId, required this.commentId});

  @override
  List<Object> get props => [expenseId, commentId];
}

class SetEditingCommentEvent extends ExpenseDetailEvent {
  final String commentId;
  final String commentText;

  const SetEditingCommentEvent({required this.commentId, required this.commentText});

  @override
  List<Object> get props => [commentId, commentText];
}

class CancelEditingCommentEvent extends ExpenseDetailEvent {}

class DeleteExpenseMediaEvent extends ExpenseDetailEvent {
  final String expenseId;
  final String mediaId;

  const DeleteExpenseMediaEvent({required this.expenseId, required this.mediaId});

  @override
  List<Object> get props => [expenseId, mediaId];
}
