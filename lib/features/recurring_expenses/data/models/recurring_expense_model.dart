import '../../domain/entities/recurring_expense_entity.dart';

class RecurringExpenseModel extends RecurringExpenseEntity {
  const RecurringExpenseModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.categoryId,
    required super.categoryName,
    required super.categoryIcon,
    required super.frequency,
    required super.dueDay,
    required super.nextDueDate,
    super.isPaused = false,
    super.autoRemind = true,
  });

  factory RecurringExpenseModel.fromJson(Map<String, dynamic> json) {
    return RecurringExpenseModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      categoryId: json['category_id']?.toString() ?? '',
      categoryName: json['category_name']?.toString() ?? 'General',
      categoryIcon: json['category_icon']?.toString() ?? 'receipt_long_rounded',
      frequency: RecurrenceFrequency.values.firstWhere(
        (e) => e.name.toLowerCase() == json['frequency']?.toString().toLowerCase(),
        orElse: () => RecurrenceFrequency.monthly,
      ),
      dueDay: (json['due_day'] as num?)?.toInt() ?? 1,
      nextDueDate: json['next_due_date'] != null
          ? DateTime.tryParse(json['next_due_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isPaused: json['is_paused'] as bool? ?? false,
      autoRemind: json['auto_remind'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category_id': categoryId,
      'category_name': categoryName,
      'category_icon': categoryIcon,
      'frequency': frequency.name,
      'due_day': dueDay,
      'next_due_date': nextDueDate.toIso8601String().split('T').first,
      'is_paused': isPaused,
      'auto_remind': autoRemind,
    };
  }
}
