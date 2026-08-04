import 'package:equatable/equatable.dart';
import 'package:split_ease/core/enums/app_enums.dart';
export 'package:split_ease/core/enums/app_enums.dart';

class RecurringExpenseEntity extends Equatable {
  final String id;
  final String title;
  final double amount;
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final RecurrenceFrequency frequency;
  final int dueDay;
  final DateTime nextDueDate;
  final bool isPaused;
  final bool autoRemind;

  const RecurringExpenseEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.frequency,
    required this.dueDay,
    required this.nextDueDate,
    this.isPaused = false,
    this.autoRemind = true,
  });

  RecurringExpenseEntity copyWith({
    String? id,
    String? title,
    double? amount,
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    RecurrenceFrequency? frequency,
    int? dueDay,
    DateTime? nextDueDate,
    bool? isPaused,
    bool? autoRemind,
  }) {
    return RecurringExpenseEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      frequency: frequency ?? this.frequency,
      dueDay: dueDay ?? this.dueDay,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isPaused: isPaused ?? this.isPaused,
      autoRemind: autoRemind ?? this.autoRemind,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        amount,
        categoryId,
        categoryName,
        categoryIcon,
        frequency,
        dueDay,
        nextDueDate,
        isPaused,
        autoRemind,
      ];
}
